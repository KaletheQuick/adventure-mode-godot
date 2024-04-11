extends MovementPackage

class_name mvpk_area_dep

@export var area_type = "water"


var LDT = 0.1 # last delta time, some error or something, idk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func transfer_situation_check(thrall : Actor) -> bool:
	return shape_check(thrall)

func release_situation_check(thrall : Actor) -> bool:
	return !shape_check(thrall)

func shape_check(thrall : Actor) -> bool:
	var shape = thrall.get_node("water_cast") #NOTE Stand in situation gantry
	for x in range(shape.get_collision_count()):
		#print(shape.get_collider(x).name)
		if shape.get_collider(x).name == area_type:
			return true
	return false


func move_thrall(thrall : Actor, delta : float):
	var old_fallVel = thrall.velocity.y
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / thrall.LDT) * 2

	# Add the gravity.
	if not thrall.is_on_floor():# && desired_move.y < 0.1:
		pass
		#thrall.velocity.y = old_fallVel # + velocity.y
		#thrall.velocity.y -= gravity * delta #no gravity for water lol
		# NOTE Special case
		#if gliding:
		#	velocity.y = clampf(velocity.y, termnalVel, 999999999)
	#print(animation_tree.get_root_motion_position().length())

	# global_basis * (animation_tree.get_root_motion_position_accumulator())
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()