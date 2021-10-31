extends CanvasLayer

onready var _camera: Camera2D
onready var _nine_patch_rect: NinePatchRect = $NinePatchRect
onready var _rich_text_label: RichTextLabel = $NinePatchRect/RichTextLabel
onready var _timer: Timer = $Timer

var _message: String = ""
var _total_message_shown: String = ""
var _text_cursor: int = 0
var _is_open: bool = false
var _default_speed: float = 0.15

signal message_started
signal message_finished

func _ready():
	_reset()

func set_message(message):
	self._message = message

func open():
	if self._message == "":
		return

	self._is_open = true
	self._nine_patch_rect.set_visible(_is_open)

	self._timer.set_wait_time(.05)
	self._timer.set_one_shot(true)
	self._timer.start()
	
func close():
	if ! self.closable():
		return
		
	self._reset()
	
func closable():
	return self._has_message_been_shown()
	
func get_is_open():
	return self._is_open

func _reset():
	self._is_open = false
	self._message = ""
	self._total_message_shown = ""
	self._text_cursor = 0

	self._nine_patch_rect.set_visible(self._is_open)
	self._rich_text_label.set_text(self._message)

func _has_message_been_shown():
	return len(self._message) > 0 and len(self._total_message_shown) == len(self._message)
	
func _process(_delta):
	if Input.is_action_pressed("ui_accept"):
		self._timer.set_wait_time(_default_speed / 6)
	else:
		self._timer.set_wait_time(_default_speed)
		
	if len(self._total_message_shown) < len(self._message) && self._timer.is_stopped():
		
		if self._text_cursor == 0:
			emit_signal("message_started")
		
		self._total_message_shown += self._message[self._text_cursor]
		
		self._rich_text_label.set_text(self._total_message_shown)
		
		self._text_cursor += 1

		self._timer.start()
		
	if self._has_message_been_shown():
		emit_signal("message_finished")
