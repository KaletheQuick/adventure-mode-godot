extends "res://addons/gut/test.gd"

var scene_path = "res://scenes/level_test.tscn"

func test_raycast_detects_open_space():
    var main_scene_resource = load(scene_path)
    var main_scene = main_scene_resource.instantiate()
    get_tree().get_root().add_child(main_scene)
    get_tree().set_current_scene(main_scene)

    wait_seconds(1)  # Making sure scene has loaded fully

    # Getting raycast node
    var raycast = main_scene.get_node("Node3D/RayCast3D")

    raycast.global_position = Vector3(0, 10, 0)  # Putting raycast in the air(open space)
    raycast.target_position = Vector3(0, -1, 0)  # Pointing raycast downwards
    raycast.enabled = true
    raycast.force_raycast_update()

    # Making sure engine has time to check collisions 
    wait_seconds(0.5)

    var is_colliding = raycast.is_colliding()

    # Checking for no collisions
    assert_eq(is_colliding, false, "Raycast is not colliding iwth anything.")
