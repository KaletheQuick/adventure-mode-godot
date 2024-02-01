extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#reference to camera node 
@onready var camera = get_node("../Camera") 


func _physics_process(delta):
	var input_dir = Vector2.ZERO

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = input_dir.normalized()

	# Getting the 3x3 matrix of camera, i.e. rotation and scaling. Does NOT include position information.
	var cam_basis = camera.global_transform.basis 

	# Accessing Z-axis vector of camera basis matrix.
	var forward = cam_basis.z.normalized()

	# Accessing X-axis vector of camera basis matrix.
	var right = cam_basis.x.normalized()


	# input_dir.x || input_dir.y is the 2D vector of the players inputs.
	# Multiplying by forward && right respectively, we we scale the vertical and horizontal inputs
	# with the 'forward' and 'right' vectors. 
	var movement_direction = forward * input_dir.y + right * input_dir.x
	if movement_direction:
		velocity.x = movement_direction.x * SPEED
		velocity.z = movement_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_TEMPORARY_fall_death()


# Resets position to origin
func _TEMPORARY_fall_death():
	if global_position.y <= -20:
		global_position = Vector3(0,1,0)