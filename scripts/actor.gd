extends CharacterBody3D

class_name Actor

@export var character : Character

var desired_move = Vector3.ZERO
var desired_turn = 0.0 # left or right -+ 
var lock_targ_pos : Vector3 = Vector3.ZERO
# NOTE - Desired move used to handle everything. But locking on and strafing 
# 		 involved having the directing you were looking, IE turned towards
#		 and the direction of movement, be separate. 

@export_group("Animation Flags")
@export var block = false
@export var parry = false
@export var attack_light = false
@export var attack_jump = false
@export var attack_heavy = false
@export var dodge = false
@export var sprint = false
@export var invulnerable = false



@onready var animation_tree : AnimationTree = $AnimationTree 
# SECTION Animation hacking system
# animation set NAME
# These hold nodes that need to be updated with various values
# See apply_animation_params to behold the shame
var aset_BLOCK = []
var aset_MOVE = []
var aset_TURN = []
var aset_JUMP = []
# !SECTION

@export_group("Movement Packages")
# 0th index is default and should always be possible to move too.
@export var movement_sets : Array[MovementPackage] # NOTE - walk_root.tres needs to be put on the child AnimationTree, otherwise there are weird control errors.
var current_moveset = 0

var combat_mode = false
var combat_relax_timer = 0

# Enums for state handedness 
enum HandState {UNARMED, ONE_HAND, TWO_HAND}
var hand_state : HandState = HandState.UNARMED

@export_group("Dress Up")
# SECTION Outfit
@export var garments : Array[Garment] # NOTE Resource references
@export_subgroup("Weapon (debug)") # TODO - replace with weapons in the Character class
@export var to_equip_wep : Accessory
var r_wep : Armament
var l_wep : Armament
# !SECTION
@export_group("Character Stats") # TODO - Replace with things in the Character class
var hurtboxes
var alive = true

# SECTION Signals 
# SECTION for leveling bar
signal killed_something
signal xp_get
signal item_get(item_name)
signal attack_hit(actor_hit, attack_id)
# !SECTION Signals
# !SECTION

@onready var start_pos = global_position

func _enter_tree() -> void:
	if name != "1" && multiplayer.get_unique_id() > 1:
		set_multiplayer_authority(str(name).to_int())
		get_parent().get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").enthrall_new_thrall(self)
		var cam_gant = get_parent().get_parent().find_child("cam_gantry_playerFollow")
		cam_gant.thrall = self
		cam_gant.cam.target_current = self
		cam_gant.freeze = false
		cam_gant.cam.freeze = false
		var netman = get_parent()
		netman.outfit_control.dress_up_controller = self.find_child("DresserUpper")

	# TODO - Remove this hack, better grouping required
	if "skele" in name:
		add_to_group("enemies")
	else:
		add_to_group("players")

func _ready():
	character = character.duplicate()
	character.reset()
	hurtboxes = find_hurtboxes_recursive(self)
	dress_up()
	compile_new_anim_tree()



## Spawn or Respawn setup
func spawn():
	character.reset()
	global_position = start_pos
	character.alive = true
	animation_tree.active = true
	current_moveset = 0
	animation_tree["parameters/playback"].travel(movement_sets[current_moveset].name)
	pass 


func find_hurtboxes_recursive(node : Node):
	var returnable = []
	for child in node.get_children():
		if "hurtbox" in child.name:
			returnable.append(child)
		else:
			returnable.append_array(find_hurtboxes_recursive(child))
	return returnable

func dethrall():
	desired_move = Vector3.ZERO
	desired_turn = Vector2.ZERO

func enthrall():
	return
	#TODO - Make check player/ai authority


func _process(delta):
	action_q_process()
	if character.health_current <= 0 and character.alive == true:
		# NOTE - A special case for death seems fine
		character.alive = false
		animation_tree.active = false
		$skeleton/AnimationPlayer.play("death")
		await get_tree().create_timer(5).timeout
		spawn()
	if character.alive == false:
		return
	character.stats_regen(delta)
	
	# TODO - get a better system for switching between movement or weapon states
	if combat_mode:
		##combat_relax_timer -= delta
		if combat_relax_timer <= 0 or Input.is_action_just_pressed("p1_item_left_next"):
			combat_mode = false

	movement_package_checks()
	movement_sets[current_moveset].move_thrall(self, delta)


func _physics_process(delta):
	if alive == false:
		return	
	apply_animation_params()	
	_TEMPORARY_fall_death()
	return




func apply_animation_params():
	# NOTE - This is a hack, i'll detail how it works.
	# all animator paramiters are iterated through,
	# their names are checked for certain keys.
	# Each key implies (ugh) a certain value type
	# Example, MOVE will be given the vector2 desired move
	# Others to come. It's awful, I know. 

	# SECTION Our current things, computing them once: 
	var transformed_move_dir =  Vector2(( global_basis.inverse() * -desired_move).x,-( global_basis.inverse() * -desired_move).z)
	for ani in aset_BLOCK:
		animation_tree.set(ani, 1 if "block" in action_q.keys() else 0)
	for ani in aset_MOVE:
		animation_tree.set(ani, transformed_move_dir)
	for ani in aset_TURN:			
		animation_tree.set(ani, desired_turn)
	for ani in aset_JUMP:
		animation_tree.set(ani, 1 if desired_move.y > 0.5 else 0)
	# !SECTION

func handle_movement(movement : Vector3):
	desired_move = movement

# Resets position to origin
func _TEMPORARY_fall_death():
	if global_position.y <= -20:
		global_position = Vector3(0,0.1,0)


func movement_package_checks():
	# Check to see if we need to move to a new state
	var state_machine = animation_tree["parameters/playback"]
	#print(state_machine.get_current_node ())
	for x in range(1, movement_sets.size()):
		if x == current_moveset:
			continue
		if movement_sets[x].transfer_situation_check(self):
			current_moveset = x
			
			state_machine.travel(movement_sets[current_moveset].name)
			return
	# Check to see if we need to bail out of our current state
	if current_moveset != 0 and movement_sets[current_moveset].release_situation_check(self):
		current_moveset = 0
		state_machine.travel(movement_sets[current_moveset].name)
		return

var attackID = 0




func awful_practice_find_parent_actor(node : Node3D):
	if node is Actor:
		return node
	else:
		return awful_practice_find_parent_actor(node.get_parent())
	

func dress_up():
	var dup = $DresserUpper as DresserUpper
	if character.base_skin != null:
		dup.garment_equip(character.base_skin)
	else:
		dup.garment_equip(character.under_skeleton)
	for garment in character.outfit:
		dup.garment_equip(garment)

	# NOTE TEST equip weapon as accessory... maybe? idk what is even going on here now
	# TODO Improve this
	if character.hand_left != null:
		character.hand_left = character.hand_left.duplicate()
		character.hand_left.bones[0] = "prop.L" # NOTE - This is a workaround
		dup.accessory_equip(character.hand_left)
		l_wep = dup.accessory_item(character.hand_left).get_child(0) as Armament
		l_wep.equip_armament(self)

	if character.hand_right != null:
		dup.accessory_equip(character.hand_right)
		r_wep = dup.accessory_item(character.hand_right).get_child(0) as Armament
		r_wep.equip_armament(self)

var damage_attack_id_buffer = []
func take_damage(damage : float, id : int) -> Armament.AttackState:
	if invulnerable:
		return Armament.AttackState.MISS # Dodged
	var returnable = Armament.AttackState.HIT
	if id not in damage_attack_id_buffer:
		damage_attack_id_buffer.append(id)
		if block && character.stamina_current > 0:
			character.stamina_current -= damage
			enque_action("blocked_attack")
			returnable = Armament.AttackState.BLOCKED
		else:
			character.health_current -= damage
		character.poise_current -= 5
		if character.poise_current <= 0:
			character.poise_regen_timer = 0.5
		else:
			character.poise_regen_timer = character.poise_regen_delay
	else:
		returnable = Armament.AttackState.MISS
	#if health_current <= 0:
	#	alive = false
	return returnable

func block_attack(id : int):
	if id not in damage_attack_id_buffer:
		damage_attack_id_buffer.append(id)
	


func compile_new_anim_tree():
	var master_tree = AnimationNodeStateMachine.new()
	var counter = 0
	for mvpk in movement_sets:
		master_tree.add_node(mvpk.name, mvpk.anim_tree, Vector2(0, counter))

	var masterstate_transition = AnimationNodeStateMachineTransition.new()
	masterstate_transition.advance_mode = AnimationNodeStateMachineTransition.ADVANCE_MODE_ENABLED
	masterstate_transition.xfade_time = 0.1
	for mvpk in movement_sets:
		for othermove in movement_sets:
			if mvpk == othermove:
				continue
			master_tree.add_transition(mvpk.name, othermove.name, masterstate_transition.duplicate())

	animation_tree.tree_root = master_tree # neat. What? No transitions or anything
	var state_machine = animation_tree["parameters/playback"]
	#state_machine.travel()
	state_machine.start(movement_sets[0].name)

	# Initialize default values
	# NOTE - This is a hack.
	# This iterates through paramiter names, then extracts default values from them, and applies them
	# This is a hack, because little things like speeds or blends are saved on the animated thing,
	# Not in the animation tree 
	var param_names = animation_tree.get_property_list() #._get_parameter_list()
	for item in param_names: # not actually param names now, still trying to get a list'
		if item.name.begins_with("parameters/"):
			if item.name.contains("SET_F["):
				var workstring = item.name.substr(item.name.find('[')+1)
				workstring = workstring.replace("-", ".") # NOTE - Another hack, param names cant have dots
				workstring = workstring.substr(0, workstring.find(']'))
				animation_tree.set(item.name, workstring.to_float())
			elif item.name.contains("MOVE") and item.name.contains("blend_position"):
				aset_MOVE.append(item.name)
			elif item.name.contains("TURN") and (item.name.contains("blend_position") or item.name.contains("add_amount")):				
				aset_TURN.append(item.name)
			elif item.name.contains("BLOCK"): # and item.name.contains("blend_position"):
				aset_BLOCK.append(item.name)
			elif item.name.contains("JUMP"): # and item.name.contains("blend_position"):
				aset_JUMP.append(item.name)


# SECTION Action Queue and buffer system
# NOTE - Action queue system. Things are put on and have a short 
# buffer time after which they are knocked off. I am not sure if this
# is a good approach, but I'm trying it out
const ACTION_Q_BUFFER_TIME = 50.0 #milliseconds
var action_q = {}

func enque_action(action : String):
	action_q[action] = Time.get_ticks_msec() + (ACTION_Q_BUFFER_TIME)
	if "attack" in action:
		combat_mode = true
		combat_relax_timer = 5.0

# Remove items that have outlived their usefulness
func action_q_process():
	var curTick = Time.get_ticks_msec()
	for key in action_q.keys():
		if action_q[key] <= curTick:
			action_q.erase(key)

func action_q_check(action : String, consume=false) -> bool: 
	# NOTE - Warning, string comparisons. Not great. 
	if action_q.size() == 0:
		return false
	if action in action_q.keys():
		if consume == true:
			action_q.erase(action)
		return true
	return false
# !SECTION - End action_q system

# SECTION - Animation assistance functions 
# To be called by animation keyframes 

# NOTE - This is somewhat undesireable. 
#        Movement code was supposed to be in the movement package
#		 Additionally, lock_targ_pos was added in as a HACK
func anim_track_look():
	if lock_targ_pos != Vector3.ZERO:
		look_at(global_position + (global_position - lock_targ_pos))
	else:
		look_at(global_position - desired_move)
	#look_at(global_position + (global_position - lock_targ_pos))

func anim_track_move():
		look_at(global_position - desired_move)
	#look_at(global_position + (global_position - lock_targ_pos))
	

@export var spell_effect : PackedScene
func anim_spell_state(state : int):
	var new_spell = spell_effect.instantiate()
	get_parent().add_child(new_spell)
	new_spell.global_position = global_position + Vector3(0,1,0) + basis.z


func anim_hurtbox_activate_right(duration : float):
	character.stamina_current -= 2
	character.stamina_regen_timer = character.stamina_regen_delay
	r_wep.activate_strike(duration)
	# TODO - left weapon

func invulnerability_time(time : float):
	var timer = get_tree().create_timer(time)
	invulnerable = true
	await timer.timeout
	invulnerable = false
# !SECTION - Animation helper functions