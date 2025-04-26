extends Control

@onready var next_button: Button = $Button

func _ready():
	get_tree().paused = true
	next_button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed():
	GameState.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()  
