extends Sprite

export var message: String

var _player: KinematicBody2D
var _message_box: CanvasLayer

func _ready():
	self._player = get_tree().get_nodes_in_group("player")[0]
	self._message_box = self._player.get_node("Camera2D/MessageBox")
	
func get_message():
	return self.message

func interact():
	if len(self.message) <= 0:
		return
		
	_player.set_frozen(true)

	_message_box.set_message(get_message())
	_message_box.open()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _message_box.get_is_open():
			if _message_box.closable():
				_player.set_frozen(false)
				_message_box.close()
