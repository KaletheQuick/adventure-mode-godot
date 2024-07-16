extends CharacterBody3D

class_name Actor

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#@onready var combo_bar = get_node("/root/level_test/CanvasLayer/ProgressBar")

@export var desired_move = Vector3.ZERO

var jump_dbounce = false # Have we recently jumped?
var LDT = 0.01 # Last delta time, calling get_process_delta_time() in the physics loop was causing issues
@export var block = false
var parry = false
@export var attack_light = false
@export var attack_jump = false
@export var attack_heavy = false
@export var dodge = false

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

# SECTION Outfit
@export var garments : Array[Garment] # NOTE Resource references

# SECTION Variables for weapon and shiled hurt/hit boxes
@export var right_weapon : ShapeCast3D
var right_ouchtime = false
@export var hit_effect : PackedScene

var hurtboxes
@export var max_health = 10.0
var health_current = 10.0
@export var max_stamina = 5.0 
var stamina_current = 5.0
var alive = true

# SECTION ~ Demo specific things
@export var demo_sit_lounge = false

# SECTION Signals for leveling bar
signal killed_something
signal xp_get
signal item_get(item_name)

func _enter_tree() -> void:
	if name != "1" && multiplayer.get_unique_id() > 1:
		set_multiplayer_authority(str(name).to_int())

		get_parent().get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").thrall = self
		var cam_gant = get_parent().get_parent().find_child("cam_gantry_playerFollow")
		cam_gant.thrall = self
		cam_gant.cam.target_current = self
		cam_gant.freeze = false
		cam_gant.cam.freeze = false
		var netman = get_parent()
		netman.outfit_control.dress_up_controller = self.find_child("DresserUpper")

func _ready():
	health_current = max_health
#	animation_tree.tree_root = defaultANIMO
	hurtboxes = find_hurtboxes_recursive(self)
	dress_up()
	compile_new_anim_tree()
	
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
	if health_current <= 0 and alive == true:
		alive = false
		animation_tree.active = false
		$skeleton/AnimationPlayer.play("death")
	if alive == false:
		return
	stamina_regen(delta)
	moveset_debug = movement_sets[current_moveset].name + ": " + animation_tree.get("parameters/playback").get_current_node()
	LDT = delta
##	if jump_dbounce and is_on_floor() and desired_move.y < 0.5: # if we have completed a jump arc, and are not desiring to jump
#		jump_dbounce = false
	if desired_move != Vector3.ZERO and desired_move.length_squared() > 0.01:
		pass
	#	$Dir_arrow.look_at(global_position + desired_move)
	if attack_light or attack_heavy or attack_jump or parry or block:
		combat_mode = true
		combat_relax_timer = 30.0
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
	if alive == false:
		return
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

func stamina_regen(delta):
	stamina_current = clamp(stamina_current + delta, 0, max_stamina)

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
			elif item.name.contains("BLOCK"): # and item.name.contains("blend_position"):
				animation_tree.set(item.name, 1 if block else 0)
			elif item.name.contains("JUMP"): # and item.name.contains("blend_position"):
				animation_tree.set(item.name, 1 if desired_move.y > 0.5 else 0)
				



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
			
			var state_machine = animation_tree["parameters/playback"]
			state_machine.travel(movement_sets[current_moveset].name)
			return
			animation_tree.tree_root = movement_sets[current_moveset].anim_tree
			animation_tree.active = false
			animation_tree.active = true
			#print("Flicker switch")
			return # quit early, good job everyone!

	# Check to see if we need to bail out of our current state
	if current_moveset != 0 and movement_sets[current_moveset].release_situation_check(self):
		current_moveset = 0
		var state_machine = animation_tree["parameters/playback"]
		state_machine.travel(movement_sets[current_moveset].name)
		return
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
		var hit_actor = awful_practice_find_parent_actor(right_weapon.get_collider(x))
		hit_actor.take_damage(2, attackID)
		attack_hit.emit(hit_actor, attackID)
		if hit_actor.health_current <= 0:
			killed_something.emit()

func awful_practice_find_parent_actor(node : Node3D):
	if node is Actor:
		return node
	else:
		return awful_practice_find_parent_actor(node.get_parent())
	
func TEMP_jumpy_check() -> bool:
	return !Input.is_action_pressed("p1_jump")

func dress_up():
	var dup = $DresserUpper as DresserUpper
	for garment in garments:
		dup.garment_equip(garment)

var damage_attack_id_buffer = []
func take_damage(damage : float, id : int):
	if id not in damage_attack_id_buffer:
		damage_attack_id_buffer.append(id)
		health_current -= damage


func compile_new_anim_tree():
	var master_tree = AnimationNodeStateMachine.new()
	var counter = 0
	for mvpk in movement_sets:
		master_tree.add_node(mvpk.name, mvpk.anim_tree, Vector2(0, counter))

	var masterstate_transition = AnimationNodeStateMachineTransition.new()
	masterstate_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED
	masterstate_transition.xfade_time = 0.1
	for mvpk in movement_sets:
		for othermove in movement_sets:
			if mvpk == othermove:
				continue
			master_tree.add_transition(mvpk.name, othermove.name, masterstate_transition.duplicate())

	animation_tree.tree_root = master_tree # neat. What? No transitions or anything
	var state_machine = animation_tree["parameters/playback"]
	#state_machine.travel()
	state_machine.start(movement_sets[0].name)

	# Initialize default values
	# NOTE - This is a hack.
	# This iterates through paramiter names, then extracts default values from them, and applies them
	# This is a hack, because little things like speeds or blends are saved on the animated thing,
	# Not in the animation tree 
	var param_names = animation_tree.get_property_list() #._get_parameter_list()
	for item in param_names: # not actually param names now, still trying to get a list'
		if item.name.begins_with("parameters/"):
			if item.name.contains("SET_F["):
				var workstring = item.name.substr(item.name.find('[')+1)
				workstring = workstring.replace("-", ".") # NOTE - Another hack, param names cant have dots
				workstring = workstring.substr(0, workstring.find(']'))
				animation_tree.set(item.name, workstring.to_float())




func dodge_hack(cost : int) -> bool:
	if dodge == true:
		print("DODGE! GO NOW!")
		# Rotate in direction of desired movement once
		look_at(global_position - desired_move)
		return true
	return false				