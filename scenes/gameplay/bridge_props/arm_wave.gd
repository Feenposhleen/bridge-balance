extends MeshInstance3D

var _tick: float = 0

func _ready() -> void:
	_tick = randf()

func _process(delta: float):
	_tick += delta
	rotation.z = cos(_tick * 4) / 2
