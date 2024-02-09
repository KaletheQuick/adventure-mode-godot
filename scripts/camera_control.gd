extends Camera3D

@export var target_current : Node3D
@export var distance = 5.0
var distance_to_target: float
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
			global_transform.origin.y = 3.0
