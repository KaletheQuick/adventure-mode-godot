extends GutTest

var Levels_load = preload("res://scripts/Leveling_Progress.gd") #script im testing (my "cool-cam")
var actor_load = preload("res://scripts/playerSocket_adventure.gd")
var Levels # variable well call .new() on 
var actors


# Script behavior, in the script we have loaded, the level_up() increases level +1, req_exp calculates exp to next level, exp_gain performs some math to get exp gain etc.

#White-box test coverage: level_up() function's correctness in the Level class aka Leveling_Progress.gd script
# Test for level saving that goes below 1, testing behavior when negative, above 30 etc.
func test_one():
	Levels = Levels_load.new() #creates new instance so we can change values without errors from godot
	#normal leveling 
	Levels.level_up()
	assert_eq(Levels.level, 2, "level_up() did not increment the level correctly")
	assert_eq(Levels.health,101,"Health was not incremented correclt after level_up()") # 2nd arg is based on already calced values for these 2
	assert_eq(Levels.strength,6,"Strength was not incremented correclt after level_up()")
	Levels.free()
	#next to check if it doesnt accept negative numbers or 0 
	Levels = Levels_load.new()
	Levels.level = -1 # sets level variable to negative
	var level_exp = Levels.level
	assert_eq(level_exp, 1 , "level should not go below negative")
	Levels.free()  # frees to prevent orphans used in rest of the tests
	#next to see 0 
	Levels = Levels_load.new() 
	Levels.level = 0 
	level_exp = Levels.level
	assert_eq(level_exp, 1,"level_up() did not reset to 1 if passed 0")
	Levels.free()



# acceptance test
#for level_up incrementing
# Test to see if the attributes level up correctly with the players level
func test_two():
	Levels = Levels_load.new()
	var Init_level = Levels.level 
	Levels.level_up()
	assert_eq(Init_level+1,Levels.level,"Initial level and level in script do not match")
	Levels.free()



# whitebox test? coverage: leveling 1-30 and our level cap not being messed up 
# Test for our 30 level cap 
func test_three():
	var c = 1 
	Levels = Levels_load.new()
	while c < 30: 
		Levels.level_up()
		c += 1
		Levels.experience = Levels.req_exp(Levels.level)
		assert_eq(Levels.level,c,"Levels didnt increment properly")
	Levels.level_up() 
	assert_eq(Levels.level, c, "Leveling past 30")
	assert_eq(Levels.experience , Levels.req_exp(30),"Experience is going over 30")
	Levels.free()



# acceptance test 
#checks if exp_gain is working properly
func test_four():
	Levels = Levels_load.new()
	var init_exp : float = Levels.experience
	Levels.exp_gain(100) # gain 100 exp 
	assert_eq(init_exp+100,Levels.experience,"Did not gain exp correctly")
	Levels.free()



# acceptance test 
#testing level_down should lose exp
func test_five():
	Levels = Levels_load.new() 
	Levels.level_up()
	Levels.experience=300
	var init_exp = Levels.experience
	var init_level=Levels.level
	Levels.level_down(300) # decrease exp by 300 which would definetly decrease level
	assert_eq(Levels.level,init_level, "Levels dont match ") # 
	assert_eq(Levels.experience,init_exp, "Experience doesn't match")
	Levels.free()




# white-box test Coverage: making sure all saved_test() function works in the Leveling_Progress Class
func test_six():
	Levels = Levels_load.new() 
	Levels.saved_level(5,9) # adds 5 to level and gives exp for 5-6 range
	assert_eq(Levels.level,5,"Level did not change to 5")
	assert_eq(Levels.experience,9,"Experience isn't the same something went wrong in saved_level")
	Levels.free()




# acceptance test
#making sure update_text() is working properly 
func test_seven():
	Levels = Levels_load.new() 
	var label_test = Levels.text_label
	Levels.level = 2 
	Levels.experience = 5
	var reqexp = Levels.req_exp(5)
	Levels.experience_required = reqexp
	Levels.update_text()
	assert_eq(Levels.test_text,"Level 2 Experience 5 / 38", "Text didn't update with respect to the level/exp") #calculated string with given level and exp
	print(Levels.test_text)
	Levels.free()




# acceptance test 
# checking the limits for req_exp and making sure its not going over 30 and under 1 
func test_eight():
	Levels = Levels_load.new() 
	var compare : float = Levels.req_exp(30)
	assert_eq(Levels.req_exp(31),compare,"Went over 30")
	Levels.req_exp(100)
	assert_eq(Levels.experience_required,compare,"Went over 30")
	Levels.req_exp(0)
	assert_eq(Levels.experience_required,Levels.req_exp(1),"Went under 1")
	Levels.req_exp(-1)
	assert_eq(Levels.experience_required,Levels.req_exp(-1),"Went under 1 (negative values)")
	Levels.free()




# acceptance test 
# testing player_death which would be used interchangably with level_down()
func test_nine():
	Levels = Levels_load.new() 
	Levels.level_up()
	Levels.level_up()
	Levels.level_up()
	var init_exp = Levels.exp_total
	print(init_exp)
	var script_loss = Levels.player_death() # player_death() will return exp lost 
	var exp_lose = init_exp - round(pow(Levels.level,2) + Levels.level *2)
	var exp_loss_test = Levels.level_down(exp_lose)
	assert_eq(exp_lose,script_loss,"player_death calculation wasnt correct")
	Levels.free()



# acceptance test
# this test will test all of our exp gain implementations, as of right now its only when player jumps but any other implementation, kill exp, exploration exp, etc. will follow the same simple format
func test_ten():
	Levels = Levels_load.new() 
	var init_exp = Levels.experience
	Input.action_press("p1_jump",true)
	assert_eq(init_exp,Levels.experience,"Experience didn't update properly with player input")
	Levels.free()



# Integration test: test if attributes level with respect to the level in playerSocket class (actor) and LevelingProgress (Levels) top-down
func test_eleven():
	Levels = Levels_load.new() 
	actors = actor_load.new()
	Levels.level_up()   # this function would update the thing we are testing
	assert_eq(Levels.health,actors.health,"Health did not update with level")
	assert_eq(Levels.strength,actors.strength,"Strength did not update with level")
	assert_eq(Levels.armor,actors.armor,"Armor did not update with level")
	Levels.free()
	actors.free()

#Integration test: test leveling with the values in actor(player) level and attributes should go up with level class (Levels) top-down
func test_twelve():
	Levels = Levels_load.new() 
	actors = actor_load.new()
	Levels.level_up() # this function in Levels should update PlayerSockets values 
	assert_eq(Levels.level,actors.level, "level didnt go to actor")
	Levels.free()
	actors.free()
