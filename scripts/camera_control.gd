extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0
var distance_to_target: float
@export var zoom_min : float  
@export var zoom_max : float 
@export var zoom_target = 1
@export var zoom_speed = 0.4
@export var cam_sens = 0.05

var prev_mouse_pos = Vector2.ZERO
var radius = 4.0
var target_curr = Vector3.ZERO
var new_position = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	prev_mouse_pos = get_viewport().get_mouse_position()
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_current):
		var target_position = target_current.global_transform.origin
		var zoom_square = zoom_target ^ 2
		target_position.y += 3
		#var distance_to_target = target_current.global_transform.origin.distance_to(global_transform.origin)
		var distance_difference = zoom_square - target_position.y
		
		if Input.is_action_just_pressed("zoom"):
			zoom_target += -15
			global_transform.origin += -global_basis.z * distance_difference * zoom_speed * delta
		
		var delta_sens = cam_sens * delta
		var curr_mouse_pos = get_viewport().get_mouse_position()
		var mouse_motion = curr_mouse_pos - prev_mouse_pos
		if mouse_motion.length() > 0 :
			print("mouse moved")
			target_curr = target_current.global_position
			var angle = mouse_motion.x * cam_sens
			var x = sin(angle) * radius
			var z = cos(angle) * radius 
			new_position = Vector3(x,3,z) + target_curr
			global_transform.origin = new_position 
			look_at_from_position(global_position,target_current.global_position,Vector3.UP)
			var new_pos_v2 = Vector2(new_position.x,new_position.y)
			prev_mouse_pos = new_pos_v2
		if Input.is_action_just_pressed("upanalog"):
			pass
		if Input.is_action_just_pressed("downanalog"):
			pass
		if Input.is_action_just_pressed("leftanalog"):
			pass
		if Input.is_action_just_pressed("rightanalog"):
			pass
		
		
		if distance_to_target > 12.0 or distance_to_target < 4.0 :
		#	pass
			#global_transform.origin = target_position - target_current.global_transform.basis.z
			global_transform.origin.y = target_position.y
