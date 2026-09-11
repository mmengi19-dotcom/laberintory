extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró en la meta es la pelota
	if body.name == "Ball":
		print("¡Nivel completado!")
		# Llamamos de forma diferida para no tocar físicas en medio del contacto
		_advance_level.call_deferred()

func _advance_level() -> void:
	var current_scene = get_tree().current_scene

	# 1. Sumamos el nivel en la interfaz
	var ui = current_scene.get_node_or_null("UI")
	if ui and ui.has_method("next_level"):
		ui.next_level()

	# 2. Regeneramos el laberinto
	# (maze.generate_maze() se encarga por sí solo de crear el mapa,
	# poner la pelota al inicio y colocar la meta en la casilla más lejana)
	var maze = current_scene.get_node_or_null("Maze")
	if maze and maze.has_method("generate_maze"):
		maze.generate_maze()
