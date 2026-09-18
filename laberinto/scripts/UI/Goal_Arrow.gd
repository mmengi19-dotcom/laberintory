extends TextureRect

@onready var ball = get_tree().current_scene.get_node("Ball")
@onready var goal = get_tree().current_scene.get_node("Goal")

var goal_found: bool = false


func _ready() -> void:
	GameManager.level_changed.connect(_on_level_changed)

	if GameManager.current_mode == GameManager.GameMode.CHALLENGE:
		show()
	else:
		hide()

	# El punto de rotación está en la base de la flecha
	pivot_offset = Vector2(0, size.y / 2)


func _process(_delta: float) -> void:
	# Si ya encontramos la meta, no hacemos nada más
	if goal_found:
		return

	# Si no estamos en Challenge, ocultar
	if GameManager.current_mode != GameManager.GameMode.CHALLENGE:
		hide()
		return

	var viewport_size = get_viewport_rect().size

	# Convertir posiciones del mundo a posiciones de pantalla
	var canvas_transform = get_viewport().get_canvas_transform()

	var ball_screen_position = canvas_transform * ball.global_position
	var goal_screen_position = canvas_transform * goal.global_position

	# Dirección hacia la meta
	var direction = goal_screen_position - ball_screen_position

	if direction.length() < 0.01:
		return

	# -----------------------------------
	# COMPROBAR SI LA META ESTÁ EN PANTALLA
	# -----------------------------------

	if goal_screen_position.x >= 0 \
	and goal_screen_position.x <= viewport_size.x \
	and goal_screen_position.y >= 0 \
	and goal_screen_position.y <= viewport_size.y:

		goal_found = true
		hide()
		return

	# -----------------------------------
	# POSICIÓN DE LA FLECHA
	# -----------------------------------

	show()

	var direction_normalized = direction.normalized()

	var arrow_distance = 100.0

	var base_position = ball_screen_position \
		+ direction_normalized * arrow_distance

	# La base de la flecha queda sobre la trayectoria
	position = base_position - pivot_offset

	# Rotar hacia la meta
	rotation = direction.angle()


func _on_level_changed(_new_level: int) -> void:
	# Nuevo nivel → volver a buscar la meta
	goal_found = false

	if GameManager.current_mode == GameManager.GameMode.CHALLENGE:
		show()
