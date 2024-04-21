extends ProgressBar

var max_health = 100
var current_health = max_health

func _ready():
    value = max_health
    update_health_label()

func reduce_health(amount):
    current_health = max(current_health - amount, 0)
    value = current_health
    update_health_label()

func update_health_label():
    var health_label = get_node("health_label")
    health_label.text = str(current_health) + " / " + str(max_health)
