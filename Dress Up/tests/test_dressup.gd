extends GutTest

var dressup_script = preload("res://Dress Up/DresserUpper.gd")
var doll

var garment_1 : Garment
var garment_2 : Garment
var garment_3 : Garment
var accessory_1 : Accessory
var accessory_2 : Accessory
var accessory_3 : Accessory

var outfit_1 : String = ""
var outfit_2 : String = ""

func before_all():
	garment_1 = Garment.new()	
	garment_1.name = "hat_of_hatting";
	garment_1.tags = ["hat","comfy","spooky"]
	garment_1.bones = ["head"]
	garment_2 = Garment.new()	
	garment_2.name = "cap of pop";
	garment_2.tags = ["hat","shady","spooky"]
	garment_2.bones = ["head"]
	garment_3 = Garment.new()	
	garment_3.name = "pant_of_vagueness";
	garment_3.tags = ["pant","comfy","indistinct"]
	garment_3.bones = ["legs"]
	accessory_1 = Accessory.new()
	accessory_1.name = "sword_of_soup"
	accessory_1.tags = ["weapon","sword","explosive"]
	accessory_1.bones = ["hand_left"]
	accessory_2 = Accessory.new()
	accessory_2.name = "knife of seasoning"
	accessory_2.tags = ["cutlery","cheese tasting","psychic"]
	accessory_2.bones = ["hand_left"]
	accessory_3 = Accessory.new()
	accessory_3.name = "shield of defenselessness"
	accessory_3.tags = ["armament","shield","explosive"]
	accessory_3.bones = ["hand_right"]

func after_all():
	pass

func before_each():	
	doll = dressup_script.new()
	doll._ready()

func after_each():
	doll.queue_free()
# test test test

# Acceptance test  - BLACK BOX
func test_garmet_equip():
	doll.garment_equip(garment_1)
	doll.garment_equip(garment_2)
	assert_eq(doll.things_worn.size(), 1, "Two items same slot, should not double up")
	

# Acceptance test  - BLACK BOX
func test_garmet_unequip():
	doll.garment_equip(garment_1)
	doll.garment_unequip(garment_1)
	assert_eq(doll.things_worn.size(), 0, "Item left on")


# Coverage test  - WHITE BOX
# Coverage of garment tweaking, reference protection. 
# Coverage is incomplete and full coverage not achived 
#	
#	func garment_tweak(gar : Garment, property_name : String, v : Variant):
#		if(gar in things_worn):
#			gar.set_garment_property(property_name, v)
#	
func test_garmet_tweak():
	# Coverage of if item is there, and if the item is not equipped, we don't tweak it.
	var gar = Garment.new() # Made here to bypass property tweaking
	gar.name = "hat_of_hatting";
	gar.tags.append_array(["hat","shady","spooky"])
	gar.bones.append("head")
	gar.set_garment_property("test_prop", 1)
	doll.garment_equip(gar)
	doll.garment_tweak(gar, "test_prop", 2)
	assert_eq(gar.properties["test_prop"],2)
	doll.garment_unequip(gar)
	doll.garment_tweak(gar, "test_prop", 3)
	assert_eq(gar.properties["test_prop"],2)


# Acceptance test  - BLACK BOX
func test_accessory_equip():
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_2)
	assert_eq(doll.things_worn.size(), 1, "Item double equipped") # Both items same slot, should not double up
	doll.accessory_equip(accessory_3)
	assert_true(doll.is_item_equipped(accessory_3), "Item not found")
	

# Acceptance test  - BLACK BOX
func test_accessory_unequep():
	doll.accessory_equip(accessory_1)
	doll.accessory_unequep(accessory_1)
	assert_eq(doll.things_worn.size(), 0, "Item unequip failure") # Both items same slot, should not double up
	doll.accessory_unequep(accessory_1)
	assert_gt(doll.things_worn.size(), -1, "Item unequip negative!") # how?

# Acceptance test  - BLACK BOX
func test_accessory_item():
	doll.accessory_equip(accessory_1)
	var worldspace_representation = doll.accessory_item(accessory_1)
	assert_not_null(worldspace_representation, "Worldspace item not present")


# Acceptance test  - BLACK BOX
func test_outfit_save():
	var expected_set = 'GARMENT:hat_of_hatting, tags=["hat", "shady", "spooky"], bones=["head"]\nACCESSORY:sword_of_soup, tags=["weapon", "sword", "explosive"], bones=["hand_left"]"\n'
	doll.garment_equip(garment_1)
	doll.garment_equip(garment_2)
	doll.garment_equip(garment_3)
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_2)
	doll.accessory_equip(accessory_3)
	var serial_data = doll.outfit_save()
	print(serial_data)
	assert_string_starts_with(serial_data, expected_set)
	assert_eq(serial_data,expected_set,"Incorrect save data")


# Acceptance test  - BLACK BOX
func test_outfit_load():
	doll.outfit_load(outfit_1)
	assert_string_starts_with(outfit_1, doll.outfit_save())


# Acceptance test  - BLACK BOX
func test_undress():
	doll.garment_equip(garment_1)
	doll.garment_equip(garment_2)
	doll.garment_equip(garment_3)
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_2)
	doll.accessory_equip(accessory_3)
	doll.undress()
	assert_eq(doll.things_worn.size(), 0)


# Acceptance test  - BLACK BOX
# 
# func conflicting_items(item):
# 	var bones = item.bones # the spots this item occupies
# 	var returnable = []
# 	for thing in things_worn:
# 		for bone in bones:
# 			if bone in thing.bones && thing not in returnable:
# 				returnable.append(thing)
# 	return returnable
# 
func test_conflict_check():
	assert_false(doll.conflict_check(garment_1), "Conflicting item on empty doll")
	doll.garment_equip(garment_1)
	#doll.garment_equip(garment_3)
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_3)
	assert_true(doll.conflict_check(garment_2), "Conflicting item not detected")
	assert_false(doll.conflict_check(garment_3), "Conflicting item on empty slot")



# Acceptance test  - BLACK BOX
func test_conflict_list():
	var special_two_slot_item = Garment.new()
	special_two_slot_item.name = "T-Shirt"
	special_two_slot_item.tags.append_array(["Nothing","Special"])
	special_two_slot_item.bones.append_array(["hand_left","head"])
	doll.garment_equip(garment_1)
	doll.garment_equip(garment_3)
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_3)
	assert_true(doll.conflicting_items(special_two_slot_item) == [garment_1, accessory_1], "Conflicting items not detected")


# Integration Test
# Tests DressUpper.gd with Actor.gd
# Primary systerm of Dress Up
func test_integratio():
	var actor = preload("res://scripts/actor.gd").new()
	actor.doll = doll
	doll.garment_equip(garment_1)
	doll.garment_equip(garment_3)
	doll.accessory_equip(accessory_1)
	doll.accessory_equip(accessory_3)
	# doll dressed
	var my_old_outfit = doll.outfit_save()
	doll.undress()
	doll.garment_equip(garment_2)
	doll.accessory_equip(accessory_2)
	assert_false(
		doll.is_item_equipped(garment_1) || 
		doll.is_item_equipped(garment_3) ||
		doll.is_item_equipped(accessory_1) ||
		doll.is_item_equipped(accessory_3),
		"Items still equipped"
	)
	doll.outfit_load(my_old_outfit)

	assert_false(
		doll.is_item_equipped(garment_2) || 
		doll.is_item_equipped(accessory_2),
		"Outfit load did not remove old items"
	)
	assert_true(my_old_outfit == doll.outfit_save(), "Outfit reversion failure")

