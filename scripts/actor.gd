extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var combo_bar = get_node("/root/level_test/CanvasLayer/ProgressBar")
@onready var combo_system = preload("combo_system.gd").new()

var desired_move = Vector3.ZERO

var jump_dbounce = false # Have we recently jumped?
var LDT = 0.01 # Last delta time, calling get_process_delta_time() in the physics loop was causing issues
var block = false
var attack_light = false

@onready var animation_tree : AnimationTree = $AnimationTree 

# SECTION Faux ModeSwitcher
@export var defaultANIMO : AnimationRootNode
@export var glideANIMO : AnimationRootNode
var termnalVel = -1.0
var gliding = false
var lastDesiredMoveY = 0
var j_bounce = false


func _ready():
	add_child(combo_system)
	#TODO IMPLEMENT SIGNAL CALL TO COMBO_SYSTEM.GD

func stop_movement():
	desired_move = Vector3.ZERO
#	velocity = Vector3.ZERO

func dethrall():
	stop_movement()

func enthrall():
	return
	#TODO - Make check player/ai authority

func _process(delta):


	LDT = delta
##	if jump_dbounce and is_on_floor() and desired_move.y < 0.5: # if we have completed a jump arc, and are not desiring to jump
#		jump_dbounce = false
	if desired_move != Vector3.ZERO and desired_move.length_squared() > 0.01:
		pass
	#	$Dir_arrow.look_at(global_position + desired_move)

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		if combo_bar:
			combo_bar.fill_combo_bar(10)

	# Get the input direction and handle the movement/deceleration.

	if gliding:
		if is_on_floor() or Input.is_action_just_pressed("p1_crouch"):
			print("Switch to walking")
			gliding = false
			animation_tree.tree_root = defaultANIMO
	else: # walking
		glideInputCheck()

	
	animation_tree.set("parameters/Move Walk/blend_position", Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z))
	if(desired_move.y > 0.5 and jump_dbounce == false) :
		jump_dbounce = true
		print(velocity.length())
		animation_tree.set("parameters/Jump w vel/blend_position", velocity.length() * 0.1) # TODO remove magic number. This is here to map a velocity range to animation blend 0-1
		animation_tree.set("parameters/conditions/jump", true)
	else:
		animation_tree.set("parameters/conditions/jump", false)
	if desired_move.y < 0.5 and jump_dbounce == true:
		jump_dbounce = false
	animation_tree.set("parameters/conditions/land", is_on_floor())
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
	animation_tree.tree_root = defaultANIMO
	animation_tree.tree_root = glideANIMO

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