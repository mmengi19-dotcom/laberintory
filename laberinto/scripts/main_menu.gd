extends Control

@onready var instructions_dialog = $InstructionsDialog
@onready var btn_start = $VBoxContainer/BtnStart
@onready var btn_instructions = $VBoxContainer/BtnInstructions
@onready var btn_quit = $VBoxContainer/BtnQuit

func _ready():
	btn_start.pressed.connect(_on_start_pressed)
	btn_instructions.pressed.connect(_on_instructions_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	# Carga la escena del juego
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_instructions_pressed():
	# Abre el cartel centrado
	instructions_dialog.popup_centered()

func _on_quit_pressed():
	# Cierra la ventana/juego
	get_tree().quit()
