extends ProgressBar

var combo_value: float = 0.0  # Adjust as needed
var drain_rate: float = 2.0  # How much to drain per second
var time_since_last_drain: float = 0.0  # Time accumulator

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
    
    if combo_value > max_value:
        combo_value = 100
        value = combo_value

func fill_combo_bar(amount: float):
    combo_value += amount
    value = clamp(combo_value, 0, max_value)
    #print("Combo bar filled to: ", value, "/", max_value)