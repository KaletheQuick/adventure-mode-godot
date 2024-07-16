extends Node3D

@onready var skele : Skeleton3D = $trail/Skeleton3D
@export var follow : Node3D

var max_cache_size = 6 * 2
var bone_chain_length = 6

var test_pos = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_pos.push_front(global_transform)
	test_pos.push_front(global_transform)
	test_pos.push_front(global_transform)
	test_pos.push_front(global_transform)
	test_pos.push_front(global_transform)
	test_pos.push_front(global_transform)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var ntrans = follow.global_transform.looking_at(Vector3.ZERO) #.scaled(Vector3.ONE * follow.global_position.length()) WAS VERY FUN!
	#ntrans.basis = ntrans.basis.scaled(Vector3.ONE * follow.global_position.length())
	test_pos.push_front(global_transform)#.rotated(global_basis.x, deg_to_rad(90))) #.affine_inverse())# * get_parent().global_transform.affine_inverse())# * global_transform.affine_inverse())
	#test_pos[0].basis = test_pos[0].basis.rotated(test_pos[0].basis.y, deg_to_rad(90))
	if test_pos.size() > max_cache_size:
		test_pos.pop_back()
	approach2()

func approach2():
	var chunky = test_pos.size() / bone_chain_length
	for x in range(6):

		var mTrans = test_pos[x*chunky]
		mTrans = global_transform.affine_inverse() * mTrans #* transform
		#mTrans = mTrans.rotated(global_transform.affine_inverse().basis.x, deg_to_rad(-90))
		skele.set_bone_global_pose_override(x,mTrans, 1)