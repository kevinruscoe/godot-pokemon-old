extends Sprite

export var message: String

var _message_box: CanvasLayer
	
func _ready():
	self._message_box = get_node("/root/Game/MessageBox")
	
func get_message():
	return self.message

func interact():
	if len(self.message) <= 0:
		return
		
	_message_box.set_message(get_message())
	_message_box.open()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _message_box.get_is_open():
			if _message_box.closable():
				_message_box.close()
