extends Node

@export var actor : Node3D 
var skele : Skeleton3D

var things_worn

# Called when the node enters the scene tree for the first time.
func _ready():
	#skele = actor.get_node("skeleton/char/Skeleton3D")
	things_worn = []
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func recursive_search_for_skele(node : Node) -> Skeleton3D:
	var returnable = null
	for child in node.get_children():
		if child is Skeleton3D:
			print("Found Skele: " +child.name)
			return child
		else:
			print("Kid?: " +child.name)
			returnable = recursive_search_for_skele(child)
	return returnable


# SECTION Dress up functions

func garment_equip(gar : Garment):
	things_worn.append(gar)

func garment_unequip(gar : Garment):
	things_worn.erase(gar)

func garment_tweak(gar : Garment, property_name : String, v : Variant):
	if(gar in things_worn):
		gar.set_garment_property(property_name, v)
	# else not found, NO FEEDBACK	

func accessory_equip(acc : Accessory):
	things_worn.append(acc)

func accessory_unequep(acc : Accessory):
	things_worn.erase(acc)

func accessory_item(acc : Accessory):
	# Find item that exists physically, and return it
	print("Item not found")
	if acc in things_worn:
		return acc.accessory
	else:
		return null

func outfit_save():
	var mes = ""
	for item in things_worn:
		mes += item.serialize() + "\n"
	return mes
	
func outfit_load(outfit_data : String):
	# fail
	print("LOAD FAILED")

func undress():
	for item in things_worn:
		unequip_item(item)

# SECTION Utility
func conflicting_items(item):
	var bones = item.bones # the spots this item occupies
	var returnable = []
	for thing in things_worn:
		for bone in bones:
			if bone in thing.bones && thing not in returnable:
				returnable.append(thing)
	return returnable

func conflict_check(item):
	var bones = item.bones # the spots this item occupies
	for thing in things_worn:
		for bone in bones:
			if bone in thing.bones:
				return true
	return false


		
func is_item_equipped(thing):
	return thing in things_worn

func unequip_item(item_removed):
	if item_removed is Accessory:
		accessory_unequep(item_removed)
	else:
		garment_unequip(item_removed)

#	
#	Dress up:
#	
#	Milestones from Git 
#		Garmet replacement - Kick off garmet in slot when equip new garmet
#		Apperance saving - save somehow, idk. ugh
#		Garmet recoloring
#		Performance impact
#		UI drag and drop
#	
#	Dress up
#		Take skinned mesh, apply to char
#			need char ref
#	
#	garmet - resource 
#		Skinned mesh (mesh + skin(armature info))
#		Tags - idk, strings? Everyone loves strings
#		Bones - specific names of bones for conflicts, NOT bones mesh applies to. 
#	
#	item - resrouce 
#		non skinned mesh 
#		Tags or something 
#	
#		equip(item, 
#	
#	
#	Functionality -
#		equip garmet 
#		tweak garmet - how do? What kind of tweaks
#			blendshapes!
#			Material properties expose how? 
#		unequip garmet (specific garmet)
#	
#	
#	
#		clear_slot(Bone to make sure nothing is on)
#	
#		equip item
#		unequip item
#		tweak item
#			blendshapes
#			material properties? 
#			Particle effects? Idk... no. This needs to be a whole item on it's own.
#	
#		undress() # clear all bones
#	
#		save_outfit() - dump out appearance to some format, idk
#	
#		load_outfit() - take serialized data and apply it to char
#	