class_name BalanceBridge
extends Node3D

@onready var _model: MeshInstance3D = $MainModel

func set_material(material: ShaderMaterial):
	_model.material_overlay = material
