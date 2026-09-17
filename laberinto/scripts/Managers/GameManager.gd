extends Node

signal state_changed(new_state)
signal level_changed(new_level)
signal key_collected

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
var has_key: bool = false

enum GameMode {
	TIME_TRIAL,  # Contrarreloj 
	CHALLENGE    # Desafío (con portales, enemigos y mecánicas extra)
}

var current_mode: GameMode = GameMode.TIME_TRIAL

func start_game(mode: GameMode = GameMode.TIME_TRIAL) -> void:
	current_mode = mode
	current_level = 1
	has_key = false # Reiniciamos la llave
	
	# El reloj solo corre si estamos en Contrarreloj
	if current_mode == GameMode.TIME_TRIAL:
		GameTimer.start()
	else:
		GameTimer.stop()
		GameTimer.reset()
		
	change_state(GameState.PLAYING)


func change_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(current_state)


func set_level(new_level: int) -> void:
	current_level = new_level
	level_changed.emit(current_level)


func next_level() -> void:
	has_key = false # Cada nuevo nivel requiere una nueva llave
	set_level(current_level + 1)


func collect_key() -> void:
	has_key = true
	key_collected.emit()
	print("¡Llave recogida!")


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
