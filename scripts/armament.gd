extends Node3D

class_name Armament # Weapon of offense or armor of defense that may be taken in hand to cast at in wrath at another.

@export var damage = 4
var ouchtime = false
@onready var hitbox = $hitbox
@onready var hitbox_vis = $hitbox/hitbox_vis
@onready var trail = $trail_weapon

var wielder : Actor # Thrall that wields this weapon
var attackID : int # random number to help prevent multi hits
@export var hit_effect : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ouchtime:
		hurtbox_check()

func equip_armament(new_wielder : Actor) -> void:
	wielder = new_wielder

func activate_strike(duration : float) -> void:
	if OS.is_debug_build():
		hitbox_vis.visible = true

	attackID = randi()

	for box in wielder.hurtboxes:
		hitbox.add_exception(box)
	hitbox.force_shapecast_update()
	ouchtime = true
	trail.restart()

	# Pause for effect
	await get_tree().create_timer(duration).timeout

	hitbox_vis.visible = false
	hitbox.clear_exceptions()
	ouchtime = false
	trail.stop() 

func hurtbox_check() -> void:	
	for x in range(hitbox.get_collision_count()):
		var nHit = hit_effect.instantiate()
		get_tree().root.add_child(nHit)
		nHit.global_position = hitbox.get_collision_point(x)
		nHit.look_at(hitbox.get_collision_point(x) + hitbox.get_collision_normal(x))
		nHit.emitting = true
		#print("OUCH!" + hitbox.get_collider(x).name)
		hitbox.add_exception_rid(hitbox.get_collider_rid(x))
		var hit_actor = awful_practice_find_parent_actor(hitbox.get_collider(x))
		hit_actor.take_damage(2, attackID)
		wielder.attack_hit.emit(hit_actor, attackID)
		if hit_actor.health_current <= 0:
			wielder.killed_something.emit()

func awful_practice_find_parent_actor(node : Node3D):
	if node is Actor:
		return node
	else:
		return awful_practice_find_parent_actor(node.get_parent())