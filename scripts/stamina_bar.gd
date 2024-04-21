extends ProgressBar


var max_stamina = 100


var current_stamina = max_stamina


var stamina_drain = 10


var regen_rate = 5


var can_regen = true


var regen_timer = 0.0
var regen_tick = 1.0 # seconds

var stamina_label : Label

func _ready():

    max_value = max_stamina

    value = current_stamina

func _process(delta):
    if can_regen and current_stamina < max_stamina:
        regen_timer += delta
        if regen_timer >= regen_tick:

            current_stamina += regen_rate

            current_stamina = min(current_stamina, max_stamina)
            #timer reset
            regen_timer = 0

            value = current_stamina

            update_stamina_label()

func use_stamina(amount = stamina_drain):
    current_stamina -= amount #drain

    current_stamina = max(current_stamina, 0)

    value = current_stamina #update stam

    update_stamina_label()
    
#    if not can_regen:     (If you'd like to delay regeneration after an attack / combo)
#        stop_stamina_regen()

#func stop_stamina_regen():

#    can_regen = false


#func start_stamina_regen():
    #can_regen = true

func update_stamina_label():

    stamina_label.text = str(current_stamina) + " / " + str(max_stamina)