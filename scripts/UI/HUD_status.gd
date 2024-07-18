extends Control

var thrall

@onready var bar_health : ProgressBar = $bar_health 
@onready var bar_stamina : ProgressBar = $bar_stamina 
@onready var bar_poise : ProgressBar = $bar_poise 

var px_per_point = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(thrall):
		bar_health.value = thrall.health_current 
		bar_stamina.value = thrall.stamina_current 
		bar_poise.value = thrall.poise_current 



func inspect_new_thrall(new_thrall : Actor):
	thrall = new_thrall

	bar_health.size.x = thrall.max_health * px_per_point
	bar_health.max_value = thrall.max_health
	bar_stamina.size.x = thrall.max_stamina * px_per_point
	bar_stamina.max_value = thrall.max_stamina
	bar_poise.size.x = thrall.max_poise * px_per_point
	bar_poise.max_value = thrall.max_poise

	