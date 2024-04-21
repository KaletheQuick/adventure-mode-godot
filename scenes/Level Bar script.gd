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
signal level_up_sig
signal update
var stats_label
@export var player_thrall : Actor
# Called when the node enters the scene tree for the first time.

func _ready():
	# NOTE - player_thrall callbacks
	player_thrall.connect("killed_something", self._killCallback)
	player_thrall.connect("xp_get", self._xp_Callback)
	player_thrall.connect("item_get", self._item_Callback)
	
	progress_bar = $Leveling_Progress # Replace with function body.
	playerSocket = $playerSocket_adventure
	update_text()
	text_label = $Level_Label
	exp_label = $Experience_Label
	
func _killCallback(): # NOTE - gains exp for kill 
	exp_gain(30)

func _item_Callback(): # NOTE - gains exp for collectable or berry collected 
	exp_gain(10)

func _xp_Callback(): # NOTE - gains 5 exp for anything else 
	exp_gain(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if level < 1:
		level = 1
	if level <= 30: 
		update_text()


func update_text():
	if text_label:
		text_label.bbcode_text = "Level %s Experience %s / %s" % [str(level), str(experience), str(experience_required)]
	test_text = "Level %s Experience %s / %s" % [str(level), str(experience), str(experience_required)]

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

func _inc_process(value):
	if value == "health":
		health += 10
	if value == "armor":
		armor += 10
	if value == "strength":
		strength += 5
	if value == "grip":
		grip += 5
	emit_signal ("update")

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
		if playerSocket:
			print("playersocket call")
			playerSocket.level = level
			playerSocket.health = health 
		exp_total = experience_required
		experience_required = req_exp(level+1)
		emit_signal("level_up_sig")

func update_stat_text(): # for menu
	pass

func stat_lookup(): # for menu
	if Input.is_action_pressed("stats"):
		pass

func reward_check():
	if level == 5: 
		item_1 == true 
	if level == 10: 
		item_2 == true 
	if level == 15:
		item_3 == true

