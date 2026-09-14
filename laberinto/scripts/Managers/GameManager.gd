extends Node

signal state_changed(new_state)
signal level_changed(new_level)


enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	LEVEL_COMPLETE,
	GAME_OVER,
	RESULTS
}


var current_state: GameState = GameState.MENU
var current_level: int = 1


func start_game() -> void:
	current_level = 1
	GameTimer.start()
	change_state(GameState.PLAYING)


func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(current_state)


func set_level(new_level: int) -> void:
	current_level = new_level
	level_changed.emit(current_level)


func next_level() -> void:
	set_level(current_level + 1)


func pause_game() -> void:
	change_state(GameState.PAUSED)
	get_tree().paused = true


func resume_game() -> void:
	get_tree().paused = false
	change_state(GameState.PLAYING)


func return_to_menu() -> void:
	get_tree().paused = false
	GameTimer.stop()
	current_level = 1
	change_state(GameState.MENU)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
