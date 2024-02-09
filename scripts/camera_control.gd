extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0

var distance_to_target: float
var target_zoom = Vector3(0,0,0)
var zoom_speed = 0.01
var initial_cam_position = Vector3(global_transform.origin)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_current):
		look_at(target_current.global_position)
		var target_position = target_current.global_transform.origin
		var distance_to_target = target_current.global_transform.origin.distance_to(global_transform.origin)
		if distance_to_target > 8.0:
			global_transform.origin = target_current.global_transform.origin - target_current.global_transform.basis.z
			global_transform.origin.y = 3
			

func _input(event):
	if event is InputEventKey:
		var key_event = event as InputEventKey 
		if Input.is_action_just_pressed("zoom"):
			var pos = global_transform.origin
			target_zoom += Vector3(0,0,-5)
			global_transform.origin = pos.lerp(target_zoom,zoom_speed)
			if target_zoom.z > -15:
				target_zoom == Vector3(0,0,0)
		
	if Input.is_action_just_pressed("cam_shift"):  # staticcamera movemnt via keyboard input
		print("V pressed")
	
	
