extends Node

func get_spawner_by_name(name: String):
	return get_node("SpawnPoints/" + name)
	
func spawn_at(spawn_name: String):
	var _player = get_tree().get_nodes_in_group("player")[0]
	var _world = get_tree().get_nodes_in_group("world")[0]
	var _spawner = self.get_spawner_by_name(spawn_name)
	
	if _spawner:
		_player.force_position(_spawner.get_entrace_point())
	else:
		_player.position = Vector2.ZERO
