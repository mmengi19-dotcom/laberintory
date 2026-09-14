extends Node2D

@onready var goal = $Goal


func _ready():
	goal.level_completed.connect(_on_level_completed)


func _on_level_completed():
	GameManager.next_level()
