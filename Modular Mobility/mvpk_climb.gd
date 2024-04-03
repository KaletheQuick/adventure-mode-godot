extends MovementPackage

class_name mvpk_climb


func transfer_situation_check(thrall : Actor) -> bool:
	# Climb when 1- airborne 2- desired movement toward climbable (any wall for now) (forward only for now)
	if thrall.is_on_floor():
		return false
	
	var space_state = thrall.get_world_3d().direct_space_state
	var origin = thrall.global_position + Vector3.UP
	var end = origin + thrall.global_basis.z
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	#print(result)
	if "collider" in result.keys() and thrall.desired_move.length() > 0.5:
		return true

	#printerr("ERROR - Not implimented")
	return false # We are abstract kinda, always not be here

func release_situation_check(thrall : Actor) -> bool:	
	if Input.is_action_just_pressed("p1_crouch"):
		return true
	return false

func move_thrall(thrall : Actor, delta : float):	
	var old_fallVel = thrall.velocity.y
	# Get the motion delta.
	thrall.velocity = ((thrall.animation_tree.get_root_motion_rotation_accumulator().inverse() * thrall.get_quaternion()) * thrall.animation_tree.get_root_motion_position() / thrall.LDT) * 2

	# Add the gravity.
	#if not thrall.is_on_floor():# && desired_move.y < 0.1:
	#	thrall.velocity.y = old_fallVel # + velocity.y
		#thrall.velocity.y -= gravity * delta
		# NOTE Special case
		#if gliding:
		#	velocity.y = clampf(velocity.y, termnalVel, 999999999)
	#print(animation_tree.get_root_motion_position().length())

	# global_basis * (animation_tree.get_root_motion_position_accumulator())
	thrall.quaternion = thrall.quaternion * ((thrall.animation_tree.get_root_motion_rotation() / delta) * 10)

	thrall.move_and_slide()