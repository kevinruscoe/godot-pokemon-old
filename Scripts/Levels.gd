extends Node

func get_spawn_point_by_name(name: String):
	return get_node("SpawnPoints/" + name)
	
func spawn_at(spawn_point_name: String):
	var _player = get_tree().get_nodes_in_group("player")[0]
	var _world = get_tree().get_nodes_in_group("world")[0]
	var _spawn_point = self.get_spawn_point_by_name(spawn_point_name)
	
	if _spawn_point:
		_player.set_frozen(true)
		_player.censor_camera()
		_player._tween.stop_all()
		_player.stop_moving()
		yield (get_tree().create_timer(.25), "timeout")
		_player.position = _spawn_point.get_entrace_position()
		_player.stop_censor_camera()
		yield (get_tree().create_timer(.25), "timeout")
		_player.set_frozen(false)
	else:
		_player.position = Vector2.ZERO
