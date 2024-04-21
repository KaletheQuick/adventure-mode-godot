extends Node3D

@export var animator : AnimationPlayer
@export var animation : String
@export var one_shot = true
var shot = false 

func trigger_animation(nothing):
	# Dirty check for player 
	print(name)
	if nothing.name != "player_actor":
		return
	if one_shot == false:
		animator.play(animation)
	elif shot == false:
		shot = true
		animator.play(animation) 