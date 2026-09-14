extends RigidBody2D

@export var tilt_force: float = 2500.0
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

# =========================
# REINICIO DE POSICIÓN Y FÍSICAS
# =========================
var _needs_reset: bool = false
var _reset_pos: Vector2 = Vector2.ZERO

func reset_to_start(start_pos: Vector2) -> void:
	_reset_pos = start_pos
	_needs_reset = true
	
	# Forzamos la actualización inmediata en el servidor de físicas
	var t = global_transform
	t.origin = start_pos
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, t)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _needs_reset:
		# Aplicamos el teletransporte dentro del ciclo exacto de físicas
		state.transform = Transform2D(0.0, _reset_pos)
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		_needs_reset = false
