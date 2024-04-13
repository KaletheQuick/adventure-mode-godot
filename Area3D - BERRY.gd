extends Area3D
@export var collect_test = false
@export var death_effect : PackedScene
signal picked_up
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collect_test:
		my_pickup_logic()
		

func my_pickup_logic():
	self.scale = Vector3(0.7, 0.7, 0.7)
	await get_tree().create_timer(0.1).timeout
	queue_free()
	$audio.play()
	emit_signal("picked_up")


