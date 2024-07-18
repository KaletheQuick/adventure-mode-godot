extends Node
# NOTE - thralling methods do not check of establis que at this time
@export var player : Actor # Just one player right now, easy mode
@onready var thrall = get_parent() as Actor

@export var dist_see = 10
@export var dist_attack = 5

var goTo : Vector3


var timer = 0.0


enum ATT_STATE {IDLE, RETREATING, ATTACKING, DODGING}
var state = ATT_STATE.IDLE

var start_pos


var dist
# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = thrall.global_position
	goTo = find_somewhere_to_go()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if thrall.alive == false:
		return
	if get_tree().get_nodes_in_group("players").size() == 0:
		return
	if is_instance_valid(player) == false:
		for play in get_tree().get_nodes_in_group("players"):
			if play is Actor and play.alive == true:
				player = play
				break
		return # find player, just come back next frame with a valid player instance	
	dist = thrall.global_position.distance_to(player.global_position)
	if dist <= dist_attack:
		in_attack_range(delta)
	elif dist <= dist_see:
		in_spot_range(delta)
	else:
		thrall.attack_light = false
	var go_dir = goTo - thrall.global_position
	thrall.handle_movement(go_dir)


func find_somewhere_to_go() -> Vector3:
	return thrall.global_position + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))


func in_spot_range(delta):
	thrall.combat_mode = true
	thrall.combat_relax_timer = 4.0
	thrall.look_at(thrall.global_position + (thrall.global_position - player.global_position))
	timer -= delta
	state = ATT_STATE.IDLE
	thrall.attack_light = false
	
func in_attack_range(delta):
	thrall.combat_mode = true
	thrall.combat_relax_timer = 4.0
	thrall.look_at(thrall.global_position + (thrall.global_position - player.global_position))
	timer -= delta
	match state:
		ATT_STATE.RETREATING:
			retreating()
			return
		ATT_STATE.DODGING:
			dodging()
			return
		ATT_STATE.ATTACKING:
			attacking()
			return
		_:
			state = ATT_STATE.DODGING


func attacking():
	#print("ATTACK")
	# Move towards player, if in some range hold attack
	thrall.attack_light = dist < 2.0
	goTo = player.global_position
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.DODGING
			timer = 4.0
		else:
			state = ATT_STATE.RETREATING
			timer = 6.0

func retreating():
	#print("RETREAT")
	thrall.attack_light = false
	# move away from player + some random side to side offset
	goTo = thrall.global_position + ((thrall.global_position - player.global_position).normalized() * 2)
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.DODGING
			timer = 4.0
		else:
			state = ATT_STATE.ATTACKING
			timer = 2.0

func dodging():
	#print("DODGE!")
	thrall.attack_light = false
	# move near player strafe around them
	thrall.dodge = true
	goTo = thrall.global_position + thrall.global_basis.x
	if timer <= 0:
		if randf() < 0.5:
			state = ATT_STATE.ATTACKING
			timer = 2.0
		else:
			state = ATT_STATE.RETREATING
			timer = 6.0

