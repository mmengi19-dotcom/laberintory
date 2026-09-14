extends Node2D

@onready var goal = $Goal


func _ready() -> void:
	goal.level_completed.connect(_on_level_completed)


func _on_level_completed() -> void:
	GameManager.next_level()
