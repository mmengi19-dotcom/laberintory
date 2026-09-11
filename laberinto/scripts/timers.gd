extends Label

var time: float = 0.0
var running: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta):
	if running:
		time += delta
		update_display()


func start_timer():
	time = 0.0
	running = true
	update_display()


func stop_timer():
	running = false


func reset_timer():
	time = 0.0
	update_display()


func get_time() -> float:
	return time


func update_display():
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var centiseconds = int((time - int(time)) * 100)

	text = "%02d:%02d.%02d" % [
		minutes,
		seconds,
		centiseconds
	]
