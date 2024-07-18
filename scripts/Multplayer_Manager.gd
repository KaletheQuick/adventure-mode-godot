extends Node

const PLAYER_SCENE = preload("res://prefabs/actor.tscn")
const PORT = 8080
var enet_peer = ENetMultiplayerPeer.new()

@export var server_menu : Control
@export var cam_gant : Node3D 
@export var cam_actu : Camera3D
@export var ip_input : LineEdit
@export var outfit_control : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_butt_host_pressed() -> void:
	server_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)

	add_player(multiplayer.get_unique_id())
	server_menu.visible = false

func _on_butt_connect_pressed() -> void:
	var server_ip = ip_input.text
	# TODO Validate ip
	server_menu.hide()
	enet_peer.create_client(server_ip, PORT)
	multiplayer.multiplayer_peer = enet_peer
	server_menu.visible = false


func add_player(peer_id):
	var new_player = PLAYER_SCENE.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	print("New player: " + str(peer_id))
	new_player.set_multiplayer_authority(peer_id)
	if peer_id == multiplayer.get_unique_id():
		print("We is us!")
		get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").enthrall_new_thrall(new_player)
		cam_gant.thrall = new_player
		cam_gant.cam.target_current = new_player
		cam_gant.freeze = false
		cam_gant.cam.freeze = false
		print("Iz noed? " + str(new_player.find_child("DresserUpper")))
		outfit_control.dress_up_controller = new_player.find_child("DresserUpper")