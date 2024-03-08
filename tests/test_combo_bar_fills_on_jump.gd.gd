extends "res://addons/gut/test.gd"

var combo_bar = null

func before_each():

    combo_bar = preload("res://scripts/combo_bar.gd").new()
    combo_bar.combo_value = 0

func test_combo_bar_fills_on_jump():
    var initial_value = combo_bar.combo_value
    combo_bar.fill_combo_bar(10)
    assert_eq(combo_bar.combo_value, initial_value + 10, "Combo bar increased properly")

func test_combo_bar_does_not_fill_when_not_jumping():
    var initial_value = combo_bar.combo_value
    
    #Checking that no unintended behaviors happen with the combo bar on idle

    wait_seconds(5)

    assert_eq(combo_bar.combo_value, initial_value, "Combo bar has not increased.")

func test_combo_bar_maximum_limit():
   
    var max_value = combo_bar.max_value
    
    combo_bar.fill_combo_bar(max_value * 2) #Going over max value
    
    wait_seconds(1)  # Wait for 1 second
    
    # Checking if combo bar has gone over max value
    assert_eq(combo_bar.combo_value, max_value, "Combo bar should NOT go past " + str(max_value) + ".")



func test_combo_bar_starts_draining():
    add_child(combo_bar)
    combo_bar.combo_value = combo_bar.max_value  # Start with the combo bar filled.
    wait_seconds(1) #1 second of game time passed

    # Checking if the combo bar drained properly
    var expected_value = max(combo_bar.max_value - combo_bar.drain_rate, 0)
    assert_false(combo_bar.combo_value < combo_bar.max_value, "Combo bar has not drained.")
    assert_true(combo_bar.combo_value >= expected_value, "Combo bar drained appropriately.")

    combo_bar.queue_free()

