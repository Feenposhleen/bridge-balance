extends Control

@onready var start_button: Button = $Button

func _ready():
	get_tree().paused = true 
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	print("Start button pressed!")
	get_tree().paused = false
	self.queue_free()
	
