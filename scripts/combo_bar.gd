extends ProgressBar

var combo_value: float = 0.0  # Adjust as needed
var drain_rate: float = 2.0  # How much to drain per second
var time_since_last_drain: float = 0.0  # Time accumulator

@export var player_actor : Actor

var current_attack_id = 0
var ignoring_actors = []

func _ready() -> void:
	player_actor.connect("attack_hit", self.attack_hit)
	print("connect attempt")

func _process(delta: float) -> void:
	time_since_last_drain += delta
	# Check if it's time to drain the combo bar
	if time_since_last_drain >= 1.0:  # Every second
		combo_value -= drain_rate
		value = clamp(combo_value, 0, max_value)  # Update the ProgressBar's value
		time_since_last_drain -= 1.0  # Reset the timer

	# Ensure the combo bar value doesn't go below 0
	if combo_value < 0:
		combo_value = 0
		value = combo_value

	# Debug test
	if player_actor.attack_heavy == true:
		print("YAYA!")
		fill_combo_bar(1.0)

func fill_combo_bar(amount: float):
	combo_value += amount
	value = clamp(combo_value, 0, max_value)
	#print("Combo bar filled to: ", value, "/", max_value)


func attack_hit(target : Actor, attack_id : int):
	print("hit!")
	if attack_id != current_attack_id:
		current_attack_id = attack_id
		ignoring_actors.clear()
	if target not in ignoring_actors:
		fill_combo_bar(35)
		ignoring_actors.append(target)