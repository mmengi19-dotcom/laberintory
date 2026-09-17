extends Area2D

signal level_completed

@export var locked_color: Color = Color(0.8, 0.2, 0.2, 0.7)  # Rojo/bloqueado
@export var open_color: Color = Color(0.2, 0.8, 0.2, 1.0)    # Verde/abierto

func _ready() -> void:
	GameManager.level_changed.connect(func(_lvl): update_visual_state())
	body_entered.connect(_on_body_entered)
	GameManager.key_collected.connect(_on_key_collected)
	update_visual_state()

# Actualiza el aspecto de la meta según el modo y si tenemos la llave
func update_visual_state() -> void:
	if GameManager.current_mode == GameManager.GameMode.CHALLENGE and not GameManager.has_key:
		modulate = locked_color
	else:
		modulate = open_color

func _on_key_collected() -> void:
	update_visual_state()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		# Si estamos en Desafío y NO tiene la llave, no pasa de nivel
		if GameManager.current_mode == GameManager.GameMode.CHALLENGE and not GameManager.has_key:
			print("¡Meta bloqueada! Necesitas la llave.")
			return

		print("¡Nivel completado!")
		level_completed.emit()
