extends Area2D

export(String, FILE, "*.tscn") var scene_path: String
export var spawn_point_name: String

signal transition_to_spawn
	
func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("transition_to_spawn", get_node("/root/Game/LevelManager"), "_on_transition_to_spawn")

func get_entrace_position():
	var rotation_degrees_normalized = int(round(rotation_degrees / 90) * 90)
	
	if rotation_degrees_normalized == 0:
		return self.position + Vector2(0, 32)
	elif rotation_degrees_normalized == 90:
		return self.position + Vector2(-64, 0)
	elif rotation_degrees_normalized == 180:
		return self.position + Vector2(-32, -64)
	elif rotation_degrees_normalized == 270:
		return self.position + Vector2(32, -32)
		
	return self.position
			
func _on_body_entered(body):
	if body == get_node("/root/Game/Player"):
		emit_signal("transition_to_spawn", self.scene_path, self.spawn_point_name)
