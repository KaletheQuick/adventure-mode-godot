extends Node

const PLAYER_SCENE = preload("res://prefabs/actor.tscn")
const PORT = 8080
var enet_peer = ENetMultiplayerPeer.new()

@export var server_menu : Control

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

func _on_butt_connect_pressed() -> void:
	server_menu.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var new_player = PLAYER_SCENE.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	print("New player: " + str(peer_id))
	#new_player.set_multiplayer_authority(peer_id)
	get_parent().find_child("Player Sockets").find_child("p1_psock_adventure").thrall = new_player