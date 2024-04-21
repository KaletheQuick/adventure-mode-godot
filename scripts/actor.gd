extends CharacterBody3D

class_name Actor

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#@onready var combo_bar = get_node("/root/level_test/CanvasLayer/ProgressBar")

var desired_move = Vector3.ZERO

var jump_dbounce = false # Have we recently jumped?
var LDT = 0.01 # Last delta time, calling get_process_delta_time() in the physics loop was causing issues
var block = false
var attack_light = false
var attack_jump = false
var attack_heavy = false
var dodge = false

signal attack_hit(actor_hit, attack_id)

@onready var animation_tree : AnimationTree = $AnimationTree 

# SECTION Faux ModeSwitcher
## 0th index is default
@export var movement_sets : Array[MovementPackage] # NOTE - walk_root.tres needs to be put on the child AnimationTree, otherwise there are weird control errors.
var current_moveset = 0
var moveset_debug = ""
@export var defaultANIMO : AnimationRootNode
@export var glideANIMO : AnimationRootNode
var termnalVel = -1.0
var gliding = false
var lastDesiredMoveY = 0
var j_bounce = false

var sprint = false

var combat_mode = false
var combat_relax_timer = 0

@export var force_switch = false

# SECTION Variables for weapon and shiled hurt/hit boxes
@export var right_weapon : ShapeCast3D
var right_ouchtime = false
@export var hit_effect : PackedScene

var hurtboxes

func _ready():
#	animation_tree.tree_root = defaultANIMO
	hurtboxes = find_hurtboxes_recursive(self)
	pass

func stop_movement():
	desired_move = Vector3.ZERO
#	velocity = Vector3.ZERO

func find_hurtboxes_recursive(node : Node):
	var returnable = []
	for child in node.get_children():
		if "hurtbox" in child.name:
			returnable.append(child)
		else:
			returnable.append_array(find_hurtboxes_recursive(child))
	return returnable

func dethrall():
	stop_movement()

func enthrall():
	return
	#TODO - Make check player/ai authority


func _process(delta):
	if force_switch:
		force_switch = false
		swap_ANIMO()
	moveset_debug = movement_sets[current_moveset].name + ": " + animation_tree.get("parameters/playback").get_current_node()
	LDT = delta
##	if jump_dbounce and is_on_floor() and desired_move.y < 0.5: # if we have completed a jump arc, and are not desiring to jump
#		jump_dbounce = false
	if desired_move != Vector3.ZERO and desired_move.length_squared() > 0.01:
		pass
	#	$Dir_arrow.look_at(global_position + desired_move)
	if attack_light or attack_heavy or attack_jump:
		combat_mode = true
		combat_relax_timer = 10.0
		for i in range(movement_sets.size()):
			if movement_sets[i] is mvpk_attack:
				current_moveset = i
				movement_sets[current_moveset].move_thrall(self, delta)
				attack_light = false
				attack_heavy = false
				attack_jump = false  # Reset the jump attack flag
				break
	if combat_mode:
		combat_relax_timer -= delta
		if combat_relax_timer <= 0:
			combat_mode = false

	movement_package_checks()

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		pass
		#velocity.y = JUMP_VELOCITY
##		if combo_bar:
#			combo_bar.fill_combo_bar(10)

	# Get the input direction and handle the movement/deceleration.
#	return
#	if gliding:
#		if is_on_floor() or Input.is_action_just_pressed("p1_crouch"):
#			print("Switch to walking")
#			gliding = false
#			animation_tree.tree_root = defaultANIMO
#	else: # walking
#		glideInputCheck()
	if right_ouchtime:
		hurtbox_check()

	
	apply_animation_params()
	#animation_tree.set("parameters/Move Walk/blend_position", Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z))
	if(desired_move.y > 0.5 and jump_dbounce == false) :
		jump_dbounce = true
		print(velocity.length())
		animation_tree.set("parameters/Jump w vel/blend_position", (desired_move * Vector3(1,0,1)).length() * 1.0) # TODO remove magic number. This is here to map a velocity range to animation blend 0-1
		animation_tree.set("parameters/conditions/jump", true)
	else:
		animation_tree.set("parameters/conditions/jump", false)
	if desired_move.y < 0.5 and jump_dbounce == true:
		jump_dbounce = false
	animation_tree.set("parameters/conditions/land", is_on_floor())


	movement_sets[current_moveset].move_thrall(self, delta)
	_TEMPORARY_fall_death()
	return
	#print(global_basis.inverse() * -desired_move)
	# NOTE - Old vel
	#if not is_on_floor():
	var old_fallVel = velocity.y
	# Get the motion delta.
	velocity = ((animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion()) * animation_tree.get_root_motion_position() / LDT) * 2

	# Add the gravity.
	if not is_on_floor():# && desired_move.y < 0.1:
		velocity.y = old_fallVel # + velocity.y
		velocity.y -= gravity * delta
		# NOTE Special case
		if gliding:
			velocity.y = clampf(velocity.y, termnalVel, 999999999)
	#print(animation_tree.get_root_motion_position().length())

	# global_basis * (animation_tree.get_root_motion_position_accumulator())
	quaternion = quaternion * ((animation_tree.get_root_motion_rotation() / delta) * 10)
	animation_tree.get_root_motion_scale()
	

	

	# Get the actual blended value of the animation.
	animation_tree.get_root_motion_position_accumulator()
	animation_tree.get_root_motion_rotation_accumulator()
	animation_tree.get_root_motion_scale_accumulator()

	move_and_slide()
	lastDesiredMoveY = desired_move.y

func swap_ANIMO():
	
	if gliding:
		animation_tree.tree_root = defaultANIMO
	else:
		animation_tree.tree_root = glideANIMO
	gliding = !gliding


func apply_animation_params():
	# NOTE - This is a hack, i'll detail how it works.
	# all animator paramiters are iterated through,
	# their names are checked for certain keys.
	# Each key implies (ugh) a certain value type
	# Example, MOVE will be given the vector2 desired move
	# Others to come. It's awful, I know. 

	# SECTION Our current things, computing them once: 
	var transformed_move_dir =  Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z)
	var param_names = animation_tree.get_property_list() #._get_parameter_list()
	for item in param_names: # not actually param names now, still trying to get a list'
		if item.name.begins_with("parameters/"):
			if item.name.contains("MOVE") and item.name.contains("blend_position"):
				animation_tree.set(item.name, transformed_move_dir)

func glideInputCheck():
	# if not groounded 
	# if desired move was 
	if is_on_floor() == false:
		if Input.is_action_just_pressed("p1_jump"):
			print("Glide")
		#if desired_move.y > 0.5 and lastDesiredMoveY < 0.1 and Input.is_action_just_pressed("p1_jump"):
			animation_tree.tree_root = glideANIMO
			gliding = true

func landed_check():
	if is_on_floor() or Input.is_action_just_pressed("p1_crouch"):
		animation_tree.tree_root = defaultANIMO


func handle_movement(movement : Vector3):
	desired_move = movement


# Resets position to origin
func _TEMPORARY_fall_death():
	if global_position.y <= -20:
		global_position = Vector3(0,1,0)


func _on_coin_body_entered(body):
	pass # Replace with function body.

func movement_package_checks():
	# Check to see if we need to move to a new state
	for x in range(1, movement_sets.size()):
		if x == current_moveset:
			continue
		if movement_sets[x].transfer_situation_check(self):
			current_moveset = x
			animation_tree.tree_root = movement_sets[current_moveset].anim_tree
			animation_tree.active = false
			animation_tree.active = true
			#print("Flicker switch")
			return # quit early, good job everyone!

	# Check to see if we need to bail out of our current state
	if current_moveset != 0 and movement_sets[current_moveset].release_situation_check(self):
		current_moveset = 0
		animation_tree.tree_root = movement_sets[current_moveset].anim_tree
		animation_tree.active = false
		animation_tree.active = true
		#print("Flicker switch")

var attackID = 0

func anim_hurtbox_activate_right(duration : float):
	for box in hurtboxes:
		right_weapon.add_exception(box)
	right_weapon.force_shapecast_update()
	right_ouchtime = true
	right_weapon.get_node("debug_hitbox").visible = true
	attackID = randi()
	await get_tree().create_timer(duration).timeout
	right_ouchtime = false
	right_weapon.get_node("debug_hitbox").visible = false
	right_weapon.clear_exceptions()

func hurtbox_check():
	for x in range(right_weapon.get_collision_count()):
		var nHit = hit_effect.instantiate()
		get_tree().root.add_child(nHit)
		nHit.global_position = right_weapon.get_collision_point(x)
		nHit.look_at(right_weapon.get_collision_point(x) + right_weapon.get_collision_normal(x))
		nHit.emitting = true
		#print("OUCH!" + right_weapon.get_collider(x).name)
		right_weapon.add_exception_rid(right_weapon.get_collider_rid(x))
		attack_hit.emit(awful_practice_find_parent_actor(right_weapon.get_collider(x)), attackID)

func awful_practice_find_parent_actor(node : Node3D):
	if node is Actor:
		return node
	else:
		return awful_practice_find_parent_actor(node.get_parent())
	
func TEMP_jumpy_check() -> bool:
	return !Input.is_action_pressed("p1_jump")
