extends Area2D

enum DIRECTIONS {NORTH, EAST, SOUTH, WEST}

export var level_name: String
export var spawn_point_name: String
export(DIRECTIONS) var exit_direction = DIRECTIONS.NORTH

var _world
var _player

onready var _exit: CollisionShape2D = $Exit

func _ready():
	_world = get_tree().get_nodes_in_group("world")[0]
	_player = get_tree().get_nodes_in_group("player")[0]
	
	connect("body_entered", self, "_on_body_entered")

func get_entrace_position():
	if exit_direction == DIRECTIONS.NORTH:
		return position + (Vector2.DOWN * 32)
	if exit_direction == DIRECTIONS.SOUTH:
		return position + (Vector2.UP * 32)
	if exit_direction == DIRECTIONS.EAST:
		return position + (Vector2.LEFT * 32)
	if exit_direction == DIRECTIONS.WEST:
		return position + (Vector2.RIGHT * 32)
		
	return position
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		_world.load_level_at_spawn_point(self.level_name, self.spawn_point_name)
