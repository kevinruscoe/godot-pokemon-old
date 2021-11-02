extends Node2D

onready var _player: Node

signal transition_started
signal transition_completed

func _enter_tree():
	self._player = get_node("/root/Game/Player")
	self.connect("transition_started", _player, "set_is_frozen", [true])
	self.connect("transition_completed", _player, "set_is_frozen", [false])
	
func _ready():
	self.set_z_index(10)
	self.visible = false
	self.get_node("ColorRect").set_size(get_viewport().get_visible_rect().size + Vector2(32, 32))
	self.get_node("ColorRect").set_frame_color(Color.black)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = _player.position - get_viewport().get_visible_rect().size / 2

func show():
	emit_signal("transition_started")
	self.visible = true
	
func hide():
	self.visible = false
	emit_signal("transition_completed")
