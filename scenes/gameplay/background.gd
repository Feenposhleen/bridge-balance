extends Node3D

const DISTANCE_LIMIT = 300

var _props: Array[Node3D] = []
var _previous_player_pos: Vector2 = Vector2.ZERO

func _ready():
	for child in get_children():
		if child is Node3D:
			_props.append(child)

	GameState.player_position.connect(_on_player_position)

func _on_player_position(player_position: Vector2):
	var y_delta = player_position.y - _previous_player_pos.y
	_previous_player_pos = player_position
	
	for child: Node3D in _props:
		child.position.z += y_delta
		if child.position.z > 20:
			child.position.z = -DISTANCE_LIMIT
		elif child.position.z < -DISTANCE_LIMIT - 1:
			child.position.z = 20
	
	
