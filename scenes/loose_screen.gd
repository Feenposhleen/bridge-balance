extends Control

@onready var retry_button: Button = $Button
@onready var description_label: Label = $Instructions

var _reason: String = ""

func _ready():
	get_tree().paused = true
	retry_button.pressed.connect(_on_retry_pressed)

	GameState.game_lose.connect(_on_game_lose)

func _on_game_lose(reason: String):
	_reason = reason
	_update_description()

func _update_description():
	if _reason == "bridge_broke":
		description_label.text = "The bridge collapsed!\nTry again and balance your moves!"
	elif _reason == "civilian_died":
		description_label.text = "Too many civilians lost!\nSave more civilians next time!"

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	self.queue_free()

func set_reason(reason: String):
	_reason = reason
	_update_description()
