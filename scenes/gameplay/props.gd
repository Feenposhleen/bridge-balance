class_name BalanceProps
extends Node3D

const _edge_padding := 7

@onready var _player: BalancePlayer = $Player

var _props: Array[BalanceProp]

var total_civilians: int = 0

func _get_tilt_at_z(z: float) -> float:
	var total_slope = 0.0
	for prop in _props:
		if prop.weight > 1:
			var z_diff = abs(prop.position.z - z);
			if z_diff < 100:
				var distance_mod = 1 - (z_diff / 100)
				total_slope += ((distance_mod * prop.weight * prop.position.x) * 0.0001)
	var player_fade = clamp(1 - (abs((z - _player.position.z)) * 0.02), 0, 1)
	return clamp(total_slope * player_fade, -0.2, 0.2)

func _ready():
	call_deferred("_add_props_from_container", self)

func _add_props_from_container(container: Node3D, reparent := false):
	for child in container.get_children():
		if child is BalancePropCollection:
			_add_props_from_container(child, true)
			remove_child(child)
		if child is BalanceProp:
			child.prop_exit.connect(_on_prop_exit)
			_props.append(child)
			
			if reparent:
				child.reparent(self, true)

	total_civilians = 0
	for prop in _props:
		if prop is BalanceCivilian:
			total_civilians += 1

func _on_prop_exit(prop: BalanceProp):
	remove_child(prop)
	_props.erase(prop)
	prop.queue_free()

func check_prop_collision(position_2d: Vector2) -> Array[BalanceProp]:
	var result: Array[BalanceProp] = []
	for prop in _props:
		if prop.weight > 1:
			if prop.position_2d.distance_squared_to(position_2d) < prop.radius_sq:
				result.append(prop)
	return result

func set_material(material: ShaderMaterial):
	for prop in _props:
		prop.set_material(material)

func _physics_process(delta: float) -> void:
	var tilt_offsets: Array[float] = []
	var tilt_values: Array[float] = []
	
	for prop in _props:
		if prop.weight > 1:
			var tilt = _get_tilt_at_z(prop.position.z)
			prop.tilt += (tilt - prop.tilt) * min(1, delta) * 0.6
			tilt_offsets.append(prop.position.z)
			tilt_values.append(prop.tilt)
	
	GameState.bridge_tilt.emit(tilt_values, tilt_offsets)
