extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var combo_bar = get_node("/root/level_test/CanvasLayer/ProgressBar")

var desired_move = Vector3.ZERO

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		print("character JUMPED")  # This will print whenever the jump button is pressed.
		if combo_bar:
			combo_bar.fill_combo_bar(10)


		if is_on_floor():
			print("Player is on floor and will jump now")
			velocity.y = JUMP_VELOCITY
		


	# Get the input direction and handle the movement/deceleration.

	var animation_tree = $AnimationTree
	animation_tree.set("parameters/blend_position", Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z))
	print(global_basis.inverse() * -desired_move)
	# Get the motion delta.
	velocity = ((animation_tree.get_root_motion_rotation_accumulator().inverse() * get_quaternion()) * animation_tree.get_root_motion_position() / delta) * 2
	# global_basis * (animation_tree.get_root_motion_position_accumulator())
	quaternion = quaternion * ((animation_tree.get_root_motion_rotation() / delta) * 10)
	animation_tree.get_root_motion_scale()
	
	

	# Get the actual blended value of the animation.
	animation_tree.get_root_motion_position_accumulator()
	animation_tree.get_root_motion_rotation_accumulator()
	animation_tree.get_root_motion_scale_accumulator()

	move_and_slide()
	_TEMPORARY_fall_death()

func handle_movement(movement : Vector3):
	desired_move = movement


# Resets position to origin
func _TEMPORARY_fall_death():
	if global_position.y <= -20:
		global_position = Vector3(0,1,0)