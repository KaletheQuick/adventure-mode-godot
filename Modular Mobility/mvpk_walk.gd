extends MovementPackage

class_name mvpk_walk

var LDT = 0.1 # last delta time, some error or something, idk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func transfer_situation_check(thrall : Actor) -> bool:
	#printerr("ERROR - Not implimented")
	return false # We are abstract kinda, always not be here

func release_situation_check(thrall : Actor) -> bool:
#	printerr("ERROR - Not implimented")
	return true # We are abstract kinda, always not be here


func move_thrall(thrall : Actor, delta : float):
	var old_fallVel = thrall.velocity.y
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / thrall.LDT) * 2

	# Add the gravity.
	if not thrall.is_on_floor():# && desired_move.y < 0.1:
		thrall.velocity.y = old_fallVel # + velocity.y
		thrall.velocity.y -= gravity * delta
		# NOTE Special case
		#if gliding:
		#	velocity.y = clampf(velocity.y, termnalVel, 999999999)
	#print(animation_tree.get_root_motion_position().length())

	# global_basis * (animation_tree.get_root_motion_position_accumulator())
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()