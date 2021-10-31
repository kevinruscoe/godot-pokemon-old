extends Node2D

var level = preload("res://Levels/Level2.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(level)
