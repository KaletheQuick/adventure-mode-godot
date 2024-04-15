extends MovementPackage

class_name mvpk_attack

# Duration for each type of attack
var light_attack_duration = 1.0
var heavy_attack_duration = 1.0
var timer = 0.0
var is_light_attack = false

func transfer_situation_check(thrall : Actor) -> bool:
    # Check if any attack trigger is active
    return thrall.attack_light or thrall.attack_heavy

func release_situation_check(thrall : Actor) -> bool:
    # Timer management to end the attack state
    timer += thrall.get_process_delta_time()
    var duration = light_attack_duration if is_light_attack else heavy_attack_duration
    if timer >= duration:
        timer = 0.0
        return true  # End the attack state after the duration
    return false

func move_thrall(thrall : Actor, delta : float):
    if thrall.attack_light:
        is_light_attack = true
        thrall.animation_tree.set("parameters/Combat/Animation", "light_attack")
        thrall.attack_light = false  # Reset the trigger
    elif thrall.attack_heavy:
        is_light_attack = false
        thrall.animation_tree.set("parameters/Combat/Animation", "heavy_attack")
        thrall.attack_heavy = false  # Reset the trigger

    # Activate the animation
    thrall.animation_tree.active = true

    # Reset velocity if you want the character to stop moving during attacks
    thrall.velocity = Vector3.ZERO
