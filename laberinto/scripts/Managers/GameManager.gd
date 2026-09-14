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


func start_game():
	current_level = 1
	change_state(GameState.PLAYING)


func change_state(new_state: GameState):
	current_state = new_state
	
func set_level(new_level: int):
	current_level = new_level
	level_changed.emit(current_level)
	
func next_level():
	set_level(current_level + 1)
