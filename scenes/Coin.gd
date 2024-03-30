extends Area3D
var rotation_speed = 1.5
var collected = false
signal _entered

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",_on_body_entered)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(rotation_speed * delta)


func _on_body_entered(body: PhysicsBody3D):
	print("entered")
	emit_signal("_entered")
