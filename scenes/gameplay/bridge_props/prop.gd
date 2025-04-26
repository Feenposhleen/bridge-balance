class_name BalanceProp
extends Node3D

signal prop_exit(prop: BalanceProp)

@export var weight := 0.0
@export var friction := 1.0
@export var radius_sq := 30.0

var tilt := 0.0
var position_2d: Vector2

var _models: Array[MeshInstance3D]
var _player_position: Vector2 = Vector2.ZERO
var _player_collided: bool = false

func _ready():
	position_2d = Vector2(global_position.x, -global_position.z)
	for child in get_children():
		if child is MeshInstance3D:
			_models.append(child)

	GameState.player_position.connect(_on_player_position)

func _on_player_position(player_position: Vector2):
	_player_position = player_position

func set_material(material: ShaderMaterial):
	for model in _models:
		model.material_overlay = material
		
func _physics_process(delta):
	if friction < 0.99:
		position_2d.x = clamp(
			position.x + (tilt * min(1, delta) * (1 - friction) * 40.),
			-BalanceProps._edge_padding,
			BalanceProps._edge_padding,
		)
	position.x = position_2d.x
	position.z = _player_position.y - position_2d.y
