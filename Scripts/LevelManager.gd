extends Node

onready var _player: Node
onready var _scene_transition_effect_manager

func _ready():

	_player = get_node("/root/Game/Player")
	
	_scene_transition_effect_manager = get_node("/root/Game/SceneTransitionEffectManager")
	
	self._load_default_level()
	
func _load_default_level():
	self._transition_scene("res://Scenes/Levels/Level1.tscn")
	self._spawn_at_position(Vector2(64, 64))
	
func _unload_current_level():
	for _child in self.get_children():
		self.remove_child(_child)
		_child.call_deferred("free")
	
func _spawn_at_position(_position: Vector2):
	self._player.position = _position
	
	yield(get_tree().create_timer(.5), "timeout")

	self._scene_transition_effect_manager.hide()
	self._player._unfreeze_for_transition()
		
func _spawn_at_point(spawn_point_name: String):	
	var _spawn_position = Vector2.ZERO
	
	if self.get_child(0).has_node(spawn_point_name):
		_spawn_position = self.get_child(0).get_node(spawn_point_name).get_entrace_position()

	self._spawn_at_position(_spawn_position)

func _transition_scene(scene_path: String):
	self._scene_transition_effect_manager.show()
	self._player._freeze_for_transition()
	
	self._unload_current_level()
				
	var loaded_scene = load(scene_path)
	
	if loaded_scene:
		var level = loaded_scene.instance()
		self.add_child(level)
	
func _on_transition_to_spawn(scene_path, spawn_point_name):
	self._transition_scene(scene_path)
	self._spawn_at_point(spawn_point_name)
