extends ProgressBar

var progress_bar = ProgressBar
var text_label
@export var level = 1 
var experience = 0 
var gain = 0
var exp_total = 0
var experience_required = req_exp(level+1)

# Called when the node enters the scene tree for the first time.
func _ready():
	progress_bar = $Leveling_Progress # Replace with function body.
	
	update_text()
	text_label = $RichTextLabel
	#update_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("p1_jump"):
		gain = 1
		exp_gain(gain)
	update_text()



func update_text():
	if text_label:
		text_label.bbcode_text = "Level %s Experience %s / %s" % [str(level), str(experience), str(experience_required)]
func req_exp(level):
	return round(pow(level,1.8) + level * 4)

func exp_gain(amount):
	print("exp gain called")
	exp_total += amount
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level_up()
	if value > 99:
			value = 0
	value = experience / experience_required * 100.0
	
func level_up():
	level+=1
	experience_required = req_exp(level+1)
