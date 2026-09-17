extends Control

@onready var instructions_dialog = $InstructionsDialog
@onready var btn_time_trial = $VBoxContainer/BtnTimeTrial
@onready var btn_challenge = $VBoxContainer/BtnChallenge
@onready var btn_instructions = $VBoxContainer/BtnInstructions
@onready var btn_quit = $VBoxContainer/BtnQuit

func _ready():
	btn_time_trial.pressed.connect(_on_time_trial_pressed)
	btn_challenge.pressed.connect(_on_challenge_pressed)
	btn_instructions.pressed.connect(_on_instructions_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

func _on_time_trial_pressed():
	GameManager.start_game(GameManager.GameMode.TIME_TRIAL)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_challenge_pressed():
	GameManager.start_game(GameManager.GameMode.CHALLENGE)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_instructions_pressed():
	instructions_dialog.popup_centered()

func _on_quit_pressed():
	get_tree().quit()
