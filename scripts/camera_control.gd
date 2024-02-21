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
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	prev_mouse_pos = get_viewport().get_mouse_position() # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_current):
		look_at(target_current.global_position)
		var target_position = target_current.global_transform.origin
		var zoom_square = zoom_target ^ 2
		target_position.y += 3
		var distance_to_target = target_current.global_transform.origin.distance_to(global_transform.origin)
		var distance_difference = zoom_square - target_position.y
		if Input.is_action_just_pressed("zoom"):
			zoom_target += -15
			if zoom_target < -150 :
				zoom_target = -15
			global_transform.origin += -global_basis.z * distance_difference * zoom_speed * delta
		if Input.is_action_just_pressed ("fov"):
			fov_value += 15
			var nt = Vector3(12,4,6)
			look_at_from_position(nt, target_current.global_position,Vector3(12,4,6))
			global_transform.origin = Vector3(12,4,6)
			if fov_value > 120: 
				fov_value = 75
			fov_value += 15
			fov = fov_value
		
		var delta_sens = cam_sens * delta
		var curr_mouse_pos = get_viewport().get_mouse_position()
		var mouse_motion = curr_mouse_pos - prev_mouse_pos
		if mouse_motion.length() > 0 :
			print("mouse moved")
			target_curr = target_current.global_position
			mox += mouse_motion.x
			var angle = mox * cam_sens
			var x = sin(angle) * radius
			var z = cos(angle) * radius
			global_transform.origin = Vector3(x,3,z) + target_current.global_position #no lerp
		if distance_to_target > 20.0 or distance_to_target < 2.0 :
			global_transform.origin = target_current.global_transform.origin - target_current.global_transform.basis.z
			global_transform.origin.y = target_position.y
