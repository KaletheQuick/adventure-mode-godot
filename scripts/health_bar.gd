extends ProgressBar

var max_health = 100
var current_health = max_health

func _ready():
    value = max_health


func reduce_health(amount):
    current_health = max(current_health - amount, 0)
    value = current_health



