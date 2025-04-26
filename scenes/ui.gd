extends Control

@onready var score_label = $RootContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Saves
@onready var total_label = $RootContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Total

func _ready() -> void:
	GameState.score.connect(_on_score_increase)

func _on_score_increase(value: int, total: int):
	score_label.text = str(value)
	total_label.text = str(total)
