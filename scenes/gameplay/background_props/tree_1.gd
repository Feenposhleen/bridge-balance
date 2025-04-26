extends MeshInstance3D

var _val: float = 0

func _ready() -> void:
	_val = randf()

func _process(delta: float):
	_val += delta
	rotation.x = (cos(_val) + sin(_val)) / 60
