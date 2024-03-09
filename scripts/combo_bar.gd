extends ProgressBar
var combo_value: float = 0.0
var drain_rate: float = 2.0
var time_since_last_drain: float = 0.0
var special_attack_cost: float = 20.0
var combo_increment: Dictionary = {
    "light_attack": 5.0,
    "heavy_attack": 10.0,
    "combo_attack": 15.0
}

func _process(delta: float) -> void:
    time_since_last_drain += delta
    if time_since_last_drain >= 1.0:
        combo_value -= drain_rate
        value = clamp(combo_value, 0, max_value)
        time_since_last_drain = 0.0

    if combo_value < 0:
        combo_value = 0
        value = combo_value

    update_combo_bar_ui()

func fill_combo_bar(amount: int) -> void:
    combo_value += amount
    update_combo_bar_ui()

func use_special_attack() -> bool:
    if combo_value >= special_attack_cost:
        combo_value -= special_attack_cost
        print("Special attack in use.")
        # TODO Logic for activating special attack animation
        return true
    else:
        print("Can't use special attack yet.")
        return false

func increment_combo(type: String) -> void:
    if type in combo_increment:
        fill_combo_bar(combo_increment[type])

func update_combo_bar_ui() -> void:
    if combo_value >= max_value * 0.8:
        modulate = Color(0, 1, 0, 1)  # Green when high
    elif combo_value > 0:
        modulate = Color(1, 1, 0, 1)  # Yellow when not empty
    else:
        modulate = Color(1, 0, 0, 1)  # Red when empty
