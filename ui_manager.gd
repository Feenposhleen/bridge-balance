extends Control

var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var win_screen_scene: PackedScene = preload("res://scenes/win_screen.tscn")
var lose_screen_scene: PackedScene = preload("res://scenes/loose_screen.tscn")

func _ready():
	if not GameState.skip_main_menu_on_reload:
		GameState.skip_main_menu_on_reload = true
		_show_main_menu()

	GameState.game_win.connect(_on_game_win)
	GameState.game_lose.connect(_on_game_lose)
func _show_main_menu():
	var menu = main_menu_scene.instantiate()
	add_child(menu)
	_center_control(menu)

func _on_game_win():
	var win = win_screen_scene.instantiate()
	add_child(win)
	_center_control(win)

func _on_game_lose(reason: String):
	var lose = lose_screen_scene.instantiate()
	add_child(lose)
	_center_control(lose)
	lose.set_reason(reason)

func _center_control(control: Control):
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0
