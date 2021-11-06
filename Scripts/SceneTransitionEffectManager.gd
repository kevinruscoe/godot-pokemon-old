extends Node

var _player: Node
onready var _node_2d: Node2D = $Node2D
onready var _color_rect: ColorRect = $Node2D/ColorRect
onready var _tween: Tween = $Node2D/Tween

signal transition_started
signal transition_completed

func _enter_tree():
	self._player = get_node("/root/Game/Player")
	self._node_2d = get_node("Node2D")
	self._color_rect = self._node_2d.get_node("ColorRect")
	self._tween = self._node_2d.get_node("Tween")

	self.connect("transition_started", _player, "set_is_frozen", [true])
	self.connect("transition_completed", _player, "set_is_frozen", [false])
	
func _ready():
	self._color_rect.set_size(get_viewport().get_visible_rect().size + Vector2(32, 32))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self._node_2d.position = _player.position - get_viewport().get_visible_rect().size / 2

func show():
	self.emit_signal("transition_started")
	self._tween.interpolate_property(
		self._color_rect,
		"color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 
		.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	self._tween.start()
	
func hide():
	self._tween.interpolate_property(
		self._color_rect,
		"color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 
		.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	self._tween.start()

	self.emit_signal("transition_completed")
