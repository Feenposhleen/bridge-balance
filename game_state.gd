extends Node

signal player_position(position: Vector2)
signal player_collision(node: Node3D)
signal bridge_tilt(tilts: Array[float], offsets: Array[float])
signal civilian_saved(civilian: BalanceCivilian)
signal civilian_died(civilian: BalanceCivilian)
signal game_win()
signal game_lose(reason: String)
signal score(score: int, total: int)
signal deaths(score: int)

var skip_main_menu_on_reload: bool = false
