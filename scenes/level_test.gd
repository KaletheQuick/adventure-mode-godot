extends Node3D

@onready var pause_menu = $Menu_Pause
var paused = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		PauseMenu()
		

func PauseMenu():
	if paused:
		pause_menu.hide()
		#Engine.time_scale = 1 
	else: 
		pause_menu.show()
		#Engine.time_scale = 0
	
	paused = !paused
	print(paused)
