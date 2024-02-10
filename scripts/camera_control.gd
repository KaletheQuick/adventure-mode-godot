extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0
var distance_to_target: float
@export var zoom_min : float  
@export var zoom_max : float 
@export var zoom_target = 1
@export var zoom_speed = 0.4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
			global_transform.origin += -global_basis.z * distance_difference * zoom_speed * delta
			
		if distance_to_target > 8.0 or distance_to_target < 2.0 :
			global_transform.origin = target_current.global_transform.origin - target_current.global_transform.basis.z
			global_transform.origin.y = target_position.y
