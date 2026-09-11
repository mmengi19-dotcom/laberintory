extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si lo que entró en la meta es la pelota
	if body.name == "Ball":
		print("¡Nivel completado!")
		# Reinicia la escena automáticamente para probar otra vez
		get_tree().call_deferred("reload_current_scene") 
		#Se puso un call_deferred pq lanzaba error al intentar recargar la escena 
		#mientras se se calculaban las fisicas.
