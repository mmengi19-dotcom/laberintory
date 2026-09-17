extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Busca la colisión de forma segura sin depender del orden de inicio
func _get_collision() -> CollisionShape2D:
	return get_node_or_null("CollisionShape2D")


# Activa y posiciona la llave en el laberinto
func setup_key(new_pos: Vector2) -> void:
	global_position = new_pos
	visible = true

	var col = _get_collision()
	if col:
		col.set_deferred("disabled", false)


# Oculta y desactiva la llave
func hide_key() -> void:
	visible = false

	var col = _get_collision()
	if col:
		col.set_deferred("disabled", true)


func _on_body_entered(body: Node2D) -> void:
	# Si la pelota la toca y está visible, la agarra
	if body.name == "Ball" and visible:
		hide_key()
		GameManager.collect_key()
