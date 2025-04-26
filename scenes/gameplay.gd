extends Node3D

var _bridge_material: ShaderMaterial = preload("res://assets/models/bridge/bridge_material.tres")
var _props_material: ShaderMaterial = preload("res://assets/models/props/props_material.tres")

@onready var _bridge: BalanceBridge = $Bridge
@onready var _props: BalanceProps = $Props
@onready var UI := $Ui
@onready var tilt_sound_player: AudioStreamPlayer3D = $TiltSoundPlayer
@onready var ambient_sound_player: AudioStreamPlayer3D = $AmbientSoundPlayer
@onready var score_sound_player: AudioStreamPlayer3D = $ScoreSoundPlayer
@onready var score_death: AudioStreamPlayer3D = $ScoreSoundKillNPC
var tilt_sounds: Array[AudioStream] = [
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound1.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound2.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound3.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound4.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound5.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound6.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound7.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound8.ogg"),
	preload("res://assets/sounds/bridge_tilt_sound/TiltSound9.ogg"),
]
var tilt_sound_cooldown: float = 0.0
var previous_avg_tilt: float = 0.0

var _player_position: Vector2 = Vector2.ZERO
var _score: int = 0
var _deaths: int = 0

func _ready() -> void:
	_props.set_material(_props_material)
	_bridge.set_material(_bridge_material)
	
	GameState.player_position.connect(_on_player_position)
	GameState.bridge_tilt.connect(_on_bridge_tilt)
	GameState.civilian_saved.connect(_on_civilian_saved);
	GameState.civilian_died.connect(_on_civilian_death);
	#GameState.score.connect(_on_score_update);
	
	ambient_sound_player.volume_db = 1  # 🎵 Nice background level
	ambient_sound_player.play()

func _on_civilian_saved(civilian: BalanceCivilian):
	_score += 1
	score_sound_player.stop()
	score_sound_player.play()
	if _score >= _props.total_civilians:
		var timer = get_tree().create_timer(2)
		await timer.timeout
		GameState.game_win.emit()
	
func _on_civilian_death(civilian: BalanceCivilian):
	_deaths += 1
	GameState.deaths.emit(_deaths)
	score_death.stop()
	score_death.play()
	
	var timer = get_tree().create_timer(2)
	await timer.timeout
	print('Game over - civilian died')
	GameState.game_lose.emit('civilian_died')

func _on_player_position(player_position: Vector2):
	GameState.score.emit(_score, _props.total_civilians)
	_player_position = player_position
	_bridge_material.set_shader_parameter('y_offset', -(player_position.y / 20))
	
func _on_bridge_tilt(tilts: Array[float], offsets: Array[float]):
	_bridge_material.set_shader_parameter('zone_positions', offsets)
	_bridge_material.set_shader_parameter('zone_tilts', tilts)
	
	_props_material.set_shader_parameter('zone_positions', offsets)
	_props_material.set_shader_parameter('zone_tilts', tilts)

	var total_tilt = 0.0
	for tilt in tilts:
		total_tilt += abs(tilt)
	
	var avg_tilt = total_tilt / tilts.size()
	
	var tilt_change = abs(avg_tilt - previous_avg_tilt)
	print(tilt_change)
	if avg_tilt > 0.02 and tilt_change > 0.0001:
		var normalized_intensity = clamp((avg_tilt - 0.05) / (0.5 - 0.05), 0.0, 1.0)
		play_random_tilt_sound(normalized_intensity)
	
	previous_avg_tilt = avg_tilt

func play_random_tilt_sound(intensity: float):
	print(tilt_sound_cooldown)
	if tilt_sound_cooldown > 0.0:
		return
	
	if tilt_sound_player.playing:
		return
	
	var random_index = randi() % tilt_sounds.size()
	tilt_sound_player.stream = tilt_sounds[random_index]
	tilt_sound_player.pitch_scale = lerp(0.95, 1.1, intensity)
	tilt_sound_player.volume_db = lerp(0, 6, intensity)
	tilt_sound_player.play()
	
	tilt_sound_cooldown = lerp(1.0, 0.3, intensity)


func _physics_process(delta):
	
	tilt_sound_cooldown -= delta
	if tilt_sound_cooldown < 0.0:
		tilt_sound_cooldown = 0.0
