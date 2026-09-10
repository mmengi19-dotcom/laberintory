extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró en la meta es la pelota
	if body.name == "Ball":
		print("¡Nivel completado!")
		# Reinicia la escena automáticamente para probar otra vez
		get_tree().reload_current_scene()
