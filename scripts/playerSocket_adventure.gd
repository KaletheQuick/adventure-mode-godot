extends Node
# What is thrall and socket model?
# Thrall means something controlled, but is also Warchief of the Horde.
# A socket plugs into a thrall and controls it. Player or AI
# Thralls take same inputs, attack, desired move direction, etc
# Easily swap socket type, ex player switch to another character
# or someone comes over the network and controlls something
# Made by KaletheQuick

@export var thrall : CharacterBody3D # the thing to be controlled 
@export var player_prefix = "p1_" # used for local multiplayer

@export var enemies : Array[Actor]
var locked_target : Actor

var primary_thrall = true

@export var mainCam : Camera3D 
@export var ganty_thing : Node3D
@export var vignette : Control
@export var title_card : Control

var dot : Node3D # debug

# Input checks for dodge vs sprint
# Soulslike = Dodge and sprint are same button. Tap or hold for difference
var dodge_sprint_threshold = 0.2
var ds_timer = 0.0

# variables for z targeting
var look_lock = false

@export var target_locker : PackedScene

# acreas and interactable things

func _ready():
	dobox(Vector3i(2,3,5))
	pass # Replace with function body.
	
	dot = target_locker.instantiate()
	get_tree().root.add_child.call_deferred(dot)
	dot.name = "~dot~"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if thrall.demo_sit_lounge == true:		
		if Input.is_action_just_pressed("p1_start") or Input.is_key_pressed(KEY_ESCAPE) or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_ALT):
			thrall.demo_sit_lounge = false
			mainCam.freeze = false
			ganty_thing.freeze = false
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(vignette, "modulate", Color(0,0,0,0.33), 3)
			var tween2 = get_tree().create_tween()
			tween2.set_ease(Tween.EASE_IN)
			tween2.set_trans(Tween.TRANS_CIRC)
			tween2.tween_property(title_card, "modulate", Color.TRANSPARENT, 1)
		return
	if thrall == null:
		return
	_collect_inputs(delta)
	#print(delta)
	find_interactable_objects()

	# NOTE - Demo purposes only



func _collect_inputs(delta):
	pass 
	# TODO - Collect player input
	# 2    - Change to relevant stuff
	# 3    - Pass forward desired inputs to thrall 

	var input_dir = Input.get_vector(player_prefix + "move_left", player_prefix + "move_right", player_prefix + "move_dn", player_prefix + "move_up")

	# Figuring out relative movement
	var mv_z = -mainCam.global_transform.basis.z
	mv_z.y = 0
	mv_z = mv_z.normalized()
	mv_z = mv_z * input_dir.y
	var mv_x = mainCam.global_transform.basis.x
	mv_x.y = 0
	mv_x = mv_x.normalized()
	mv_x = mv_x * input_dir.x
	var go_dir = (mv_x + mv_z)

	go_dir.y = Input.get_axis(player_prefix + "crouch", player_prefix + "jump")
	
	# SECTION - Dodge and sprinting
	if Input.is_action_just_released(player_prefix + "dodge"):
		if ds_timer <= dodge_sprint_threshold:
			print("dodge!")
	if Input.is_action_pressed(player_prefix + "dodge"):
		ds_timer += delta
		if ds_timer > dodge_sprint_threshold:
			thrall.sprint = true
			thrall.dodge = true
	else:
		thrall.sprint = false
		thrall.dodge = false
		ds_timer = 0
	
	thrall.handle_movement(go_dir)
	thrall.block = true if Input.get_action_strength("p1_block") > 0.5 else false
	thrall.attack_light = true if Input.get_action_strength("p1_attack_light") > 0.5 else false
	thrall.attack_heavy = true if Input.get_action_strength("p1_attack_heavy") > 0.5 and thrall.attack_light == false else false


	dot.global_position = thrall.global_position + go_dir

	# SECTION - Camera and lock on stuff
	if Input.is_action_just_pressed(player_prefix + "look_lock"):
		look_lock = !look_lock
		if look_lock:
			print("look lock")
			# FIXME - thrall logic in socket
			thrall.combat_mode = true
			thrall.combat_relax_timer = 3.0
			# Find target closest to center forward of screen.
			var winner = null
			var win_dot = 10.0
			for enemy in enemies:
				# easy out checks 
				if enemy.alive == false:
					continue
				if thrall.global_position.distance_to(enemy.global_position) > 20:
					continue
				# cull front half of camera? wait, vector math? here?
				var my_dot = mainCam.global_basis.z.dot((enemy.global_position - mainCam.global_position).normalized())
				if my_dot < win_dot:
					winner = enemy
					win_dot = my_dot
			if winner != null:
				locked_target = winner
			else:
				locked_target = null
				look_lock = false
				ganty_thing.look_at(thrall.global_position + (thrall.global_basis.z * 50))

		else:
			print("look unlock")
	if look_lock:
		mainCam.target_curr = locked_target.global_position + Vector3(0,2,0)
		dot.global_position = locked_target.global_position + Vector3(0,2,0)
		dot.visible = true
		# FIXME ~ HACK - turning should be handled by the animation and thrall control system!
		var og_rot = thrall.global_rotation_degrees
		thrall.look_at(thrall.global_position + (thrall.global_position - locked_target.global_position))
		thrall.global_rotation_degrees.x = 0
		thrall.global_rotation_degrees.z = 0
		dot.look_at(mainCam.global_position)
		dot.get_node("TargetReticle").rotate_z(delta) #(dot.global_basis.z.normalized(), delta)
		dot.scale = Vector3.ONE + (Vector3.ONE * ((1 + (sin(Time.get_unix_time_from_system() * 12)*0.5))) * 0.5 )
	else:
		dot.visible = false
		mainCam.target_curr = Vector3.ZERO


@export var action_prompt : Control
func find_interactable_objects():
	pass 
	# TODO - Sphere cast or ray cast for items. 
	# TODO - Reevaluate object interaction for more generic use

	# Phys ray
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = thrall.global_position + Vector3.UP
	var end = origin + (thrall.global_basis.z * 2)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var col_result = space_state.intersect_ray(query)

	#if is_instance_valid(col_result):
	if "collider" in col_result.keys():
		#print(col_result)
		if col_result["collider"] is Harvestable:
			var crop = col_result["collider"] as Harvestable
			action_prompt.show_prompt(crop.harvest_name)
			if Input.is_action_just_pressed(player_prefix + "event_action") and col_result["collider"].collected == false:
				col_result["collider"].my_pickup_logic()
				thrall.item_get.emit("fruit")
	else:
		action_prompt.hide_prompt()




func dobox(box : Vector3i):
	for x in range(box.x):
		for y in range(box.y):
			for z in range(box.z):
				print("pos:(", x, ",", y, ",", z, ")")