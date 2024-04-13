extends CharacterBody3D

class_name Actor

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var combo_bar = get_node("/root/level_test/CanvasLayer/ProgressBar")

var desired_move = Vector3.ZERO

var jump_dbounce = false # Have we recently jumped?
var LDT = 0.01 # Last delta time, calling get_process_delta_time() in the physics loop was causing issues
var block = false
var attack_light = false
var attack_jump = false
var attack_heavy = false

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

@export var force_switch = false

# SECTION Variables for weapon and shiled hurt/hit boxes
@export var right_weapon : ShapeCast3D
var right_ouchtime = false
@export var hit_effect : PackedScene

func _ready():
#	animation_tree.tree_root = defaultANIMO
	pass

func stop_movement():
	desired_move = Vector3.ZERO
#	velocity = Vector3.ZERO

func dethrall():
	stop_movement()

func enthrall():
	return
	#TODO - Make check player/ai authority

func _input(event):
	if event.is_action_pressed("p1_attack_light"):
		attack_light = true  # Set flag for light attack
	elif event.is_action_pressed("heavy_attack"):
		attack_heavy = true  # Set flag for heavy attack
	elif event.is_action_pressed("jump_attack"):
		attack_jump = true  # Set flag for jump attack

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
		for i in range(movement_sets.size()):
			if movement_sets[i] is mvpk_attack:
				current_moveset = i
				movement_sets[current_moveset].move_thrall(self, delta)
				attack_light = false
				attack_heavy = false
				attack_jump = false  # Reset the jump attack flag
				break

	movement_package_checks()

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		if combo_bar:
			combo_bar.fill_combo_bar(10)

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

	
	animation_tree.set("parameters/Move Walk/blend_position", Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z))
	if(desired_move.y > 0.5 and jump_dbounce == false) :
		jump_dbounce = true
		print(velocity.length())
		animation_tree.set("parameters/Jump w vel/blend_position", (desired_move * Vector3(1,0,1)).length() * 0.1) # TODO remove magic number. This is here to map a velocity range to animation blend 0-1
		animation_tree.set("parameters/conditions/jump", true)
	else:
		animation_tree.set("parameters/conditions/jump", false)
	if desired_move.y < 0.5 and jump_dbounce == true:
		jump_dbounce = false
	animation_tree.set("parameters/conditions/land", is_on_floor())


	movement_sets[current_moveset].move_thrall(self, delta)
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
	_TEMPORARY_fall_death()
	lastDesiredMoveY = desired_move.y

func swap_ANIMO():
	
	if gliding:
		animation_tree.tree_root = defaultANIMO
	else:
		animation_tree.tree_root = glideANIMO
	gliding = !gliding


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
			return # quit early, good job everyone!

	# Check to see if we need to bail out of our current state
	if movement_sets[current_moveset].release_situation_check(self):
		current_moveset = 0
		animation_tree.tree_root = movement_sets[current_moveset].anim_tree
		#animation_tree.active = false
		#animation_tree.active = true

var attackID = 0

func anim_hurtbox_activate_right(duration : float):
	right_weapon.add_exception(self)
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
		print("OUCH!" + right_weapon.get_collider(x).name)
		right_weapon.add_exception_rid(right_weapon.get_collider_rid(x))
