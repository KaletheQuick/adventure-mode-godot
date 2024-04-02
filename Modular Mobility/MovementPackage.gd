extends Resource

class_name MovementPackage

@export var name : String
@export var anim_tree : AnimationRootNode

@export var anim_library : AnimationLibrary

var thrall : CharacterBody3D

func apply():
	pass

func transfer_situation_check():
	pass

func release_situation_check():
	pass