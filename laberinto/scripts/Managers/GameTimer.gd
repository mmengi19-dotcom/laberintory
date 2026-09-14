extends Node

signal time_changed(time: float)

var time: float = 0.0
var running: bool = false

var last_centiseconds: int = -1


func _process(delta: float):
	if not running:
		return

	time += delta

	var centiseconds = int(time * 100)

	if centiseconds != last_centiseconds:
		last_centiseconds = centiseconds
		time_changed.emit(time)


func start():
	time = 0.0
	running = true
	last_centiseconds = -1
	time_changed.emit(time)


func stop():
	running = false


func reset():
	time = 0.0
	running = false
	last_centiseconds = -1
	time_changed.emit(time)


func get_time() -> float:
	return time
