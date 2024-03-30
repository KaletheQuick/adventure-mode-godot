extends Control
@onready var main = $"../Level Bar"
@onready var pause_menu = $"../Menu_Pause"


func _on_button_pressed():
	self.hide()
	pause_menu.show()
