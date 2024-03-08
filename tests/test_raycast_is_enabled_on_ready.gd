extends "res://addons/gut/test.gd"

var scene_path = "res://scenes/level_test.tscn"  # Adjust this to the correct path

func test_raycast_is_enabled_on_ready():
    # Load scene
    var main_scene_resource = load(scene_path)

    var main_scene = main_scene_resource.instantiate()
    get_tree().get_root().add_child(main_scene)
    # Wait until the scee has fully loadedn

    #Getting raycast node.
    var raycast = main_scene.get_node("Node3D/RayCast3D")

    #Asserting that raycast node is enabled on _ready.
    assert_true(raycast.enabled, "Raycast enabled properly.")

