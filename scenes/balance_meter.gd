extends Node2D

@onready var arc = $Arc
@onready var arrow = $Arrow

var center_point = Vector2.ZERO
var start_point = Vector2.ZERO
var control_point = Vector2.ZERO
var end_point = Vector2.ZERO
@onready var collapse_sound_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var t = -0.7
var blink_timer = 0.0
var tension := 0.0

func _ready():
	center_point = arc.global_position
	
	start_point = center_point + Vector2(-140, 0)
	control_point = center_point + Vector2(0, -80)
	end_point = center_point + Vector2(140, 0)
	
	GameState.bridge_tilt.connect(_on_bridge_tilt)

func _on_bridge_tilt(tilt_values: Array, tilt_offsets: Array):
	if tilt_values.is_empty():
		return
	
	var total_tilt = 0.0
	for tilt in tilt_values:
		total_tilt += tilt
	total_tilt /= tilt_values.size()
	
	var tilt_strength = 0.1
	
	t = clamp(total_tilt / tilt_strength, -0.5, 0.5)


func _process(delta):
	var pos = get_point_on_curve(t)
	var dir = get_curve_direction(t)

	var arrow_offset = Vector2(0, -80)
	arrow.global_position = pos + arrow_offset
	arrow.rotation = dir.angle()
	
	var blink_start_threshold = 0.2
	var danger_threshold = 0.4
	
	if abs(t) > blink_start_threshold:
		var danger_level = clamp((abs(t) - blink_start_threshold) / (danger_threshold - blink_start_threshold), 0.0, 1.0)
		blink_timer += delta * 20.0 * danger_level
		
		var safe_color = Color(1, 1, 1)
		var danger_color = Color(1, 0, 0)
		var blink_color = safe_color.lerp(danger_color, danger_level)
		
		var alpha = abs(sin(blink_timer))
		
		arc.modulate = Color(blink_color.r, blink_color.g, blink_color.b, alpha)
		
		var pre_tension = tension
		if danger_level > 0.9:
			tension += delta
		else:
			tension = max(0, tension - delta)
			
		if pre_tension < 2 && tension > 2:
			
			collapse_sound_player.play()
			var timer = get_tree().create_timer(3)
			await timer.timeout
			GameState.game_lose.emit('bridge_broke')
			print('Game over - bridge broke')
	else:
		arc.modulate = Color(1, 1, 1, 1)
	

func get_point_on_curve(t: float) -> Vector2:
	var mapped_t = clamp(t + 0.5, 0.0, 1.0)
	return (1 - mapped_t) * (1 - mapped_t) * start_point + 2 * (1 - mapped_t) * mapped_t * control_point + mapped_t * mapped_t * end_point

func get_curve_direction(t: float) -> Vector2:
	var mapped_t = clamp(t + 0.5, 0.0, 1.0)
	var derivative = 2 * (1 - mapped_t) * (control_point - start_point) + 2 * mapped_t * (end_point - control_point)
	return derivative.normalized()
