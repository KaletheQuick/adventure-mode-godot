extends Node

# Exported stats mean we can just change them from the editor.
@export var strength = 10
@export var agility = 10
@export var intelligence = 10

# Constitution stats.
@export var health = 100
@export var mana = 50

#Skill points.
var skill_points = 3
var skills = {
    "Hack": false,
    "Slash": false,
    "Stab": false
}

func increase_stat(stat_name: String, amount: int):
    match stat_name:
        "strength":
            strength += amount
        "agility":
            agility += amount
        "intelligence":
            intelligence += amount
        "health":
            health += amount
        "mana":
            mana += amount
        _:
            print("Invalid stat name")
            return

func decrease_stat(stat_name: String, amount: int):
    match stat_name:
        "strength":
            strength -= amount
        "agility":
            agility -= amount
        "intelligence":
            intelligence -= amount
        "health":
            health = max(0, health - amount) # Prevent negatives.
        "mana":
            mana = max(0, mana - amount) # Prevent negatives.
        _:
            print("Invalid stat name")
            return

func unlock_skill(skill_name: String):
    if skill_points <= 0:
        print("Not enough skill points.")
        return
    if not skills.has(skill_name):
        print("Skill does not exist.")
        return
    if skills[skill_name]:
        print("Skill already unlocked.")
        return
        
    skills[skill_name] = true
    skill_points -= 1
    print(skill_name + " has been unlocked!")

func add_skill_points(amount: int):
    skill_points += amount
    print("Added " + str(amount) + " skill points. Total now: " + str(skill_points))

func is_skill_unlocked(skill_name: String) -> bool:
    if skills.has(skill_name):
        return skills[skill_name]
    print("Skill DNE")
    return false

func update_ui_or_logic_based_on_new_stats():
    pass
