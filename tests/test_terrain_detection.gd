extends "res://addons/gut/test.gd"

var scene_path = "res://scenes/level_test.tscn"  # Adjust this to the correct path

func test_terrain_detection():
    # Load the scene and instance it
    var main_scene_resource = load(scene_path)

    var main_scene = main_scene_resource.instantiate()
    get_tree().get_root().add_child(main_scene)
    get_tree().set_current_scene(main_scene)


    # Getting raycast node
    var raycast = main_scene.get_node("Node3D/RayCast3D")
    
    # Configure the raycast and perform the test
    raycast.global_position = Vector3(0,2, 0)  # Position raycast source in open space
    raycast.target_position = Vector3(0, -1, 0)
    raycast.enabled = true
    raycast.force_raycast_update()


    var is_colliding = raycast.is_colliding()

    wait_seconds(2)

    # Checking for collision
    assert_eq(is_colliding, true, "Raycast collided with terrain properly.")
    
    # Cleanup: remove the main scene from the scene tree
    main_scene.queue_free()