extends Node


signal combo_triggered(combo_name)

var input_sequence = []
var last_input_time = 0.0
var input_timeout = 1.5  # Break combo timer if this much time has elapsed.

var combos = {
    'light_heavy_light': ['attack_light', 'attack_heavy', 'attack_light'], 'heavy_light_light': ['attack_heavy', 'attack_light', 'attack_light'],
 
}

func _ready():
    # Ensure this system is always processing to check for combo timeouts
    set_process(true)

func _process(delta):
    if last_input_time > 0 and (Time.get_ticks_msec() / 1000.0 - last_input_time) > input_timeout:
        input_sequence.clear()  # Reset combo timer
        last_input_time = 0

func add_input(input_action):
    input_sequence.append(input_action)
    last_input_time = Time.get_ticks_msec() / 1000.0  # Update last input time
    check_for_combos()

#apparently this checks for combos. Will look into it more at a later date. 
func check_for_combos():
    for combo_name in combos.keys():
        var combo_sequence = combos[combo_name]
        if input_sequence.size() >= combo_sequence.size() and input_sequence.slice(-combo_sequence.size(), -1) == combo_sequence:
            execute_combo(combo_name)  # Execute combo rewards
            break 

func execute_combo(combo_name: String):
    print("Combo executed: ", combo_name)
    
    #Checking the combo name and applying a reward based on it
    match combo_name:
        "light_heavy_jump":
            # Reward for this specific combo
            increase_damage(1.5)
            gain_experience(100)
        #"another_combo_name":

# Placeholder function for gaining extra damage from combos
func increase_damage(multiplier: float):
    pass

# Placeholder function for gaining extra exp from combos
func gain_experience(amount: int):
    pass