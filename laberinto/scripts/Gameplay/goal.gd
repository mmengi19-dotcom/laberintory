extends Area2D

signal level_completed


func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró en la meta es la pelota
	if body.name == "Ball":
		print("¡Nivel completado!")

		# Avisamos que el nivel terminó
		level_completed.emit()
