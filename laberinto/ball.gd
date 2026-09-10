extends RigidBody2D

@export var tilt_force: float = 1200.0
@export var deadzone: float = 0.4

func _ready() -> void:
	gravity_scale = 0.0

func _physics_process(_delta: float) -> void:

	# =========================
	# TECLADO
	# =========================
	var move_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	# =========================
	# ACELERÓMETRO
	# =========================
	var accel = Input.get_accelerometer()

	

	if accel.length() > 0.1:

		# Convertimos acelerómetro a movimiento 2D
		var sensor_input = Vector2(
			accel.x,
			-accel.y
		)

		# Zona muerta
		if sensor_input.length() > deadzone:
			move_dir = sensor_input / 9.8
		else:
			move_dir = Vector2.ZERO

	# =========================
	# APLICAR FUERZA
	# =========================
	if move_dir != Vector2.ZERO:
		apply_central_force(move_dir * tilt_force)
