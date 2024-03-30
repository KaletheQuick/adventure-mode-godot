extends Control

@onready var main = $"../"
@onready var stats = $"../Stats"


func _on_resume_pressed():
	main.PauseMenu()

func _on_stats_pressed():
	self.hide()
	stats.show()


func _on_exit_pressed():
	get_tree().quit()

