extends "res://addons/gut/test.gd"


func test_movement_stops_on_dethrall():

    var character = preload("res://prefabs/actor.tscn").instantiate()
    get_tree().get_root().add_child(character)

    #We are simulating movement here
    character.desired_move = Vector3(1, 0, 0)
    character.dethrall() # Should stop the movement

    # Check if movement stopped
    assert_eq(character.desired_move, Vector3.ZERO, "Actors movement properly stopped.")

    character.queue_free()