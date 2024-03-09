extends Resource
class_name Garment

var name
# SECTION Visuals of garmet
@export var mesh : Mesh
@export var skin : Skin
@export var mate : Material
# SECTION OTHER DATA
@export var tags : Array[String]
@export var bones : Array[String]

var properties = {}

func spawn_garmet() -> MeshInstance3D:
	var garmet = MeshInstance3D.new()
	garmet.mesh = self.mesh
	garmet.set_surface_override_material(0,  self.mate)
		# NOTE Only one surface supported, mesh data not modified
		# TODO Evaluate different approach
	garmet.skin = self.skin # Skin contains mesh weight data, I think. We will find out.
	return garmet

func set_garment_property(p_name : String, value : Variant):
	properties[p_name] = value

func get_garment_property(p_name : String):
	return properties[p_name]


func serialize() -> String:
	return "GARMENT:" + name + ", tags=" + str(tags) + ", bones=" + str(bones)