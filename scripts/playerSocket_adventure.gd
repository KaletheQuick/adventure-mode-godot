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
@export var test_second_thrall : CharacterBody3D
var primary_thrall = true

@export var mainCam : Camera3D 

var dot : MeshInstance3D # debug

# Input checks for dodge vs sprint
# Soulslike = Dodge and sprint are same button. Tap or hold for difference
var dodge_sprint_threshold = 0.2
var ds_timer = 0.0

# variables for z targeting
var look_lock = false

func _ready():
	pass # Replace with function body.
	
	#debug
	var sphere = SphereMesh.new()
	sphere.radial_segments = 7
	sphere.radius = 0.125
	sphere.height = 0.25
	dot = MeshInstance3D.new()
	dot.mesh = sphere
	get_tree().root.add_child.call_deferred(dot)
	dot.name = "~dot~"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if thrall == null:
		return
	_collect_inputs(delta)
	#print(delta)
	return
	if Input.is_action_just_pressed("p1_dodge"):		
		primary_thrall = !primary_thrall
		if primary_thrall: 
			test_second_thrall.dethrall()
			thrall.enthrall()
			mainCam.target_current = thrall
			#print("Character 1 Enthralled.")
		else:
			thrall.dethrall() 
			test_second_thrall.enthrall()
			mainCam.target_current = test_second_thrall
			#print("Character 2 Enthralled")


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
	else:
		thrall.sprint = false
		ds_timer = 0
	
	thrall.handle_movement(go_dir)
	thrall.block = true if Input.get_action_strength("p1_block") > 0.5 else false
	thrall.attack_light = true if Input.get_action_strength("p1_attack_light") > 0.5 else false


	dot.global_position = thrall.global_position + go_dir

	# SECTION - Camera and lock on stuff
	if Input.is_action_just_pressed(player_prefix + "look_lock"):
		look_lock = !look_lock
		if look_lock:
			print("look lock")
		else:
			print("look unlock")
	if look_lock:
		mainCam.target_curr = test_second_thrall.global_position + Vector3(0,2,0)
		dot.global_position = test_second_thrall.global_position + Vector3(0,2,0)
	else:
		mainCam.target_curr = Vector3.ZERO

