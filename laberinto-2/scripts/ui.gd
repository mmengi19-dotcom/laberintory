extends CanvasLayer

@onready var pause_btn = $BtnPause
@onready var pause_menu = $PauseMenu
@onready var btn_resume = $PauseMenu/VBoxContainer/BtnResume
@onready var btn_main_menu = $PauseMenu/VBoxContainer/BtnMainMenu

func _ready():
	pause_btn.pressed.connect(_on_pause_pressed)
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_main_menu.pressed.connect(_on_main_menu_pressed)

func _on_pause_pressed():
	print("Pausando...")
	get_tree().paused = true
	pause_menu.visible = true
	pause_btn.visible = false

func _on_resume_pressed():
	print("Reanudando...")
	get_tree().paused = false
	pause_menu.visible = false
	pause_btn.visible = true

func _on_main_menu_pressed():
	print("Yendo al menú principal...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
