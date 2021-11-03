extends Node

var _player: Node
var _node_2d: Node2D
var _color_rect: ColorRect

signal transition_started
signal transition_completed

func _enter_tree():
	self._player = get_node("/root/Game/Player")
	self._node_2d = get_node("Node2D")
	self._color_rect = self._node_2d.get_node("ColorRect")

	self.connect("transition_started", _player, "set_is_frozen", [true])
	self.connect("transition_completed", _player, "set_is_frozen", [false])
	
func _ready():
	self._color_rect.set_size(get_viewport().get_visible_rect().size + Vector2(32, 32))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self._node_2d.position = _player.position - get_viewport().get_visible_rect().size / 2

func show():
	self.emit_signal("transition_started")
	self._node_2d.visible = true
	
func hide():
	self._node_2d.visible = false
	_message_boxemit_signal("transition_completed")
