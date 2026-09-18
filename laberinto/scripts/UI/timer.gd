extends Label


func _ready():
	GameTimer.time_changed.connect(_on_time_changed)

	# Mostrar el valor actual al iniciar
	_on_time_changed(GameTimer.get_time())


func _on_time_changed(new_time: float):
	var minutes = float(new_time) / 60
	var seconds = int(new_time) % 60
	var centiseconds = int(new_time * 100) % 100

	text = "%02d:%02d.%02d" % [
		minutes,
		seconds,
		centiseconds
	]
