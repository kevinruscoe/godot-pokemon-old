extends Area2D

export var entrance = Vector2.ZERO
export var level_name: String
export var spawn_name: String

var _world
var _player

func _ready():
	_world = get_tree().get_nodes_in_group("world")[0]
	_player = get_tree().get_nodes_in_group("player")[0]
	
	connect("body_entered", self, "_on_body_entered")

func get_entrace_point():
	print(global_position + entrance, global_position , entrance)
	return global_position + entrance
	
func set_entrance(value):
	entrance = value

func get_entrace():
	return entrance

func _on_body_entered(body):
	if body.is_in_group("player"):
		_world.load_level_at_spawn(self.level_name, self.spawn_name)
