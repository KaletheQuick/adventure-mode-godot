extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0
var distance_to_target: float
@export var zoom_min : float  
@export var zoom_max : float 
@export var zoom_target = 1
@export var zoom_speed = 0.4
@export var cam_sens = 0.05
var fov_value = 75
var follow_speed = 5.0
var prev_mouse_pos = Vector2.ZERO
var radius = 4.0
var target_curr = Vector3.ZERO
var new_position = Vector3.ZERO
var mox = 0 
var smoothing = 0.1 

# SECTION New shit
var cam_velocity = Vector3.ZERO
var leash_dist_current = 4
var follow_offset = Vector3(0, 3, 0.001)

var cam_rot_velocity = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#prev_mouse_pos = get_viewport().get_mouse_position() # Replace with function body.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_current) == false: # Guard clause style, baby!
		return 

	# Order 
	# follow
	_follow()
	# move
	# look
	_look()
	# zoom ? 
	global_position += cam_velocity * delta
	#rotation_degrees.y += cam_rot_velocity.x * (cam_rot_velocity.x**2)
	#rotation_degrees.x += cam_rot_velocity.y * (cam_rot_velocity.y**2)
	#rotation_degrees.x = clampf(rotation_degrees.x, -60, 80)


func _follow():
	var dir_to_target = (target_current.global_position + follow_offset) - global_position
	#print(dir_to_target)
	var dist_beyond_leash = leash_dist_current - dir_to_target.length()
	dist_beyond_leash = dist_beyond_leash**2 if dist_beyond_leash >0 else -(dist_beyond_leash**2 )
	dir_to_target = dir_to_target.normalized()
	cam_velocity = -dir_to_target * dist_beyond_leash
	# add in extra Y movement to keep the camera on our desired plane
	var y_mov = global_position.y  - (target_current.global_position.y + follow_offset.y)
	cam_velocity.y -= y_mov

func _look():
	# transform target to screen space
	var target_screenPos = unproject_position(target_current.global_position)
	var midscreen = get_viewport().size / 2
	var target_vector = (global_position-target_current.global_position).normalized()
	var something = global_basis.z
	something.y = 0
	something = something.normalized()
	var x_rot = (something).signed_angle_to(target_vector -Vector3(0,target_vector.y, 0), Vector3.UP)
	something = (global_basis.z -global_basis.x).normalized()
	var y_rot = (global_basis.z).signed_angle_to(target_vector-global_basis.x, Vector3.LEFT)
	#var difference = midscreen - target_screenPos
	cam_rot_velocity.x = x_rot * 10
	cam_rot_velocity.y = (midscreen.y - target_screenPos.y) * 0.06 
	print(cam_rot_velocity)
#	look_at(target_current.global_position)