extends Node2D

var _level

func _ready():
	self.load_default_level()
	
	
func load_default_level():
	self.load_level("Level1")
	$Player.position = Vector2(64, 64)
	$Player.set_frozen(true)
	$Player.stop_censor_camera()
	$Player/Camera2D/MessageBox.set_message("Welcome to\nPOKeMON")
	$Player/Camera2D/MessageBox.open()
	
func load_level(level_name: String):
	var level_resource = load("res://Levels/" + level_name + ".tscn")
	
	if level_resource:
		
		$Player.censor_camera()

		for current_level in get_node("Level").get_children():
			get_node("Level").remove_child(current_level)
			current_level.call_deferred("free")

		_level = level_resource.instance()
		
		get_node("Level").add_child(_level)
		
		return true
		
	return false

func load_level_at_spawn(level_name: String, spawn_name: String):
	if load_level(level_name):
		_level.spawn_at(spawn_name)
		
		return true
		
	return false
