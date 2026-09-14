extends CanvasLayer

@onready var pause_btn = $BtnPause
@onready var pause_menu = $PauseMenu
@onready var btn_resume = $PauseMenu/VBoxContainer/BtnResume
@onready var btn_main_menu = $PauseMenu/VBoxContainer/BtnMainMenu
@onready var level_label = $LevelLabel

#var current_level: int = 1

func _ready():
	pause_btn.pressed.connect(_on_pause_pressed)
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_main_menu.pressed.connect(_on_main_menu_pressed)
	
	# Inicializamos el texto en el nivel 1
	#_update_level_display()
	GameManager.level_changed.connect(_on_level_changed)
	_on_level_changed(GameManager.current_level)

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

# Función para avanzar de nivel
func _on_level_changed(new_level):
	if level_label:
		level_label.text = "Nivel %d" % new_level
