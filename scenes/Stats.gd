extends Control
@onready var pause_menu = $"../Menu_Pause"
var level_label 
var l_c = 0
signal level_inc(value)

func _ready():
	level_label = $Stats_Label
	var level_node = get_node("../user_interface/LevelBar")
	_update_text()
	level_node.connect("level_up_sig",_on_level)
	level_node.connect("update",_update_text)
	
func _update_text():
	var level_node = get_node("../user_interface/LevelBar")
	var lb_level = level_node.level
	var lb_health = level_node.health
	var lb_armor = level_node.armor
	var lb_strength = level_node.strength
	var lb_grip = level_node.grip
	level_label.text = "Level: " + str(lb_level) + "\n \n Health: " + str(lb_health) + "\n \n Armor: " + str(lb_armor) + "\n \n Strength: " + str(lb_strength) + "\n\n Grip: " + str(lb_grip)
func _on_level():
	_update_text()
	l_c += 1
	$Control.show()

func _on_button_pressed():
	self.hide()
	pause_menu.show()

func _on_health_inc_pressed():
	l_c -= 1
	if l_c == 0:
		$Control.hide()
	emit_signal("level_inc","health")

func _on_armor_inc_pressed():
	l_c -= 1
	if l_c == 0:
		$Control.hide()
	emit_signal("level_inc","armor")

func _on_strength_inc_pressed():
	l_c -= 1
	if l_c == 0:
		$Control.hide()
	emit_signal("level_inc","strength")

func _on_grip_inc_pressed():
	l_c -= 1
	if l_c == 0:
		$Control.hide()
	emit_signal("level_inc","grip")
