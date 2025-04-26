class_name BalancePlayer
extends BalanceProp

@onready var _main_model: MeshInstance3D = $MainModel
@onready var _motor_sound: AudioStreamPlayer3D = $MotorSound

const _max_speed = 10
const _agility = 20

var _rotation_velocity := 0.0
var _speed_velocity := 0.0
var _actual_player_position := Vector2.ZERO
var _wheels: Array[MeshInstance3D]
var _props: BalanceProps

func _ready():
	var parent = get_parent()
	if parent is BalanceProps:
		_props = parent

	_models.append(_main_model)
	for child in _main_model.get_children():
		_models.append(child)
		if child is MeshInstance3D:
			_wheels.append(child)
			_models.append(child)
	
	_motor_sound.volume_db = -20
	_motor_sound.pitch_scale = 1

func _get_direction_vector() -> Vector2:
	return Vector2(
		cos(_main_model.rotation.y + (PI / 2)),
		sin(_main_model.rotation.y + (PI / 2))
	)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		_rotation_velocity = min(_max_speed / 4, _rotation_velocity + (delta * _agility))
	elif Input.is_action_pressed("move_right"):
		_rotation_velocity = max(-_max_speed / 4, _rotation_velocity - (delta * _agility))
	else:
		_rotation_velocity = _rotation_velocity * max(1 - (delta * _agility), 0)
	
	if Input.is_action_pressed("move_forward"):
		_speed_velocity = clamp(_speed_velocity + (delta * _agility), 4, _max_speed)
	elif Input.is_action_pressed("move_backward"):
		_speed_velocity = max(-_max_speed, _speed_velocity - (delta * _agility))
	else:
		_speed_velocity = _speed_velocity * max(1 - (delta * _agility), 0)
	
	if (abs(_rotation_velocity) > 0.001):
		_main_model.rotate_y(_rotation_velocity * delta)
	
	if (abs(_speed_velocity) > 0.001):
		var velocity_vector := (_get_direction_vector() * delta * _speed_velocity)
		var new_player_position = _actual_player_position + velocity_vector
		
		var colliders := _props.check_prop_collision(new_player_position)
		for collider in colliders:
			if collider != self && collider.weight > 1:
				var collider_pos_2d = collider.position_2d
				var prev_collider_distance = collider_pos_2d.distance_to(_actual_player_position)
				var new_collider_distance = collider_pos_2d.distance_to(new_player_position)
				if (new_collider_distance < prev_collider_distance):
					new_player_position = _actual_player_position
					
		
		new_player_position.x = clamp(
			new_player_position.x,
			-BalanceProps._edge_padding,
			BalanceProps._edge_padding
		)
		
		_actual_player_position = new_player_position
		position.x = _actual_player_position.x
		position_2d = _actual_player_position
		GameState.player_position.emit(_actual_player_position)
		
		for wheel in _wheels:
			wheel.rotate_x(-_speed_velocity * delta)

		var speed = abs(_speed_velocity)
		
		_motor_sound.pitch_scale = clamp(1.0 + speed * 0.05, 1.0, 1.3)


		
