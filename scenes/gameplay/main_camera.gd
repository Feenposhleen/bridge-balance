extends Camera3D

var _target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameState.player_position.connect(_on_player_position)

func _on_player_position(player_position: Vector2):
	_target_position = Vector2(player_position.x, 0)

func _physics_process(delta: float) -> void:
	position.x += (_target_position.x - position.x) * 0.1
	
