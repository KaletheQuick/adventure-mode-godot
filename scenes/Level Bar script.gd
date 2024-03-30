extends ProgressBar
@export var health = 100
@export var strength = 5
@export var grip = 20
@export var armor = 5
var progress_bar = ProgressBar
var text_label
var exp_label
var level = 1 
var experience = 0 
var gain = 0
var exp_total = 0
var experience_required = req_exp(level+1)
var exp_loss
var level_prompt = false
var save_file = false 
var playerSocket 
var test_text
var item_1 = false 
var item_2 = false 
var item_3 = false
var exp_multiplier = false
var player_position

# Called when the node enters the scene tree for the first time.

func _ready():
	progress_bar = $Leveling_Progress # Replace with function body.
	playerSocket = $playerSocket_adventure
	update_text()
	text_label = $Level_Label
	exp_label = $Experience_Label
	var terrain = $terrain
	var area = get_node("../../terrain/Coin")
	if area:
		area.connect("_entered",_area_entered)
	else: 
		print("coin not found")
func _area_entered():
	exp_gain(10)
	print("print entered")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if level < 1:
		level = 1
	
	#if Input.is_action_pressed("p1_jump"):
		#gain = 1
		#exp_gain(gain)
	if level <= 30: 
		update_text()


func update_text():
	if text_label:
		text_label.bbcode_text = "Level %s Experience %s / %s" % [str(level), str(experience), str(experience_required)]
	test_text = "Level %s Experience %s / %s" % [str(level), str(experience), str(experience_required)]

func zone_discovered():
	exp_gain(10)

func req_exp(level):
	if level < 1: 
		return round(pow(1,1.8) + 1 * 4)
	if level >= 30: 
		return round(pow(30,1.8) + 30 * 4)
	if level >= 1:
		return round(pow(level,1.8) + level * 4)

func exp_gain(amount):
	if exp_multiplier:
		amount += amount * 2
	exp_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
	if value > 99:
			value = 0
	value = experience / experience_required * 100.0

func saved_level(level_save,exp):
	level = level_save
	exp_gain(exp)
	var c = 1 
	while  c <= level_save: 
		level_up()
		c += 1
	req_exp(level)
	reward_check()

func player_death():
	exp_loss = experience - round(pow(level,2) + level *2)
	level_down(exp_loss)
	return exp_loss

func level_down(exp_loss):
	if exp_loss < req_exp(level):
		if level > 1:
			level -= 1
			var stat = level/0.5 
			health -= stat 
			strength -= stat 
			armor -= stat
			grip -= stat 
	experience_required = req_exp(level+1)

func debuff_effect(ammount):
	var factor = ammount
	level -= ammount
	strength -= ammount/3
	health -= ammount/3
	armor -= ammount/3
	await 10
	debuff_disable(ammount)

func debuff_disable(factor):
	level += factor
	strength += factor *3
	health += factor * 3
	armor += factor * 3 

func level_up():
	if level <= 30:
		level+=1
		level_prompt= true
		var stat = level/0.5 
		health += 1
		strength += 1 
		armor += 1 
		grip += 1
		if playerSocket:
			print("playersocket call")
			playerSocket.level = level
			playerSocket.health = health 
		exp_total = experience_required
		experience_required = req_exp(level+1)

func update_stat_text():
	pass

func stat_lookup():
	if Input.is_action_pressed("stats"):
		pass

func reward_check():
	if level == 5: 
		item_1 == true 
	if level == 10: 
		item_2 == true 
	if level == 15:
		item_3 == true

