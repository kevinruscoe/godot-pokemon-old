extends Sprite

export var message: String

var _ui_manager: Node
var _message_box: Node
	
func _enter_tree():
	self._ui_manager = self.get_node("/root/Game/UIManager")
	self._message_box = self._ui_manager.get_node("MessageBox")

func get_message():
	return self.message

func interact():
	if len(self.message) <= 0:
		return
		
	self._message_box.set_message(get_message())
	self._message_box.open()
