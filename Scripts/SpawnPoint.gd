extends Area2D

enum DIRECTIONS {NORTH, EAST, SOUTH, WEST}

export(String, FILE, "*.tscn") var scene_path: String
export var spawn_point_name: String
export(DIRECTIONS) var exit_direction = DIRECTIONS.NORTH

signal transition_to_spawn
	
func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("transition_to_spawn", get_node("/root/Game/LevelManager"), "_on_transition_to_spawn")

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
	print(body, get_node("/root/Game/Player"))
	if body.is_in_group("player"):
		emit_signal("transition_to_spawn", self.scene_path, self.spawn_point_name)
