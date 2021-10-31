extends KinematicBody2D

const TILE_SIZE: int = 32

export var speed: float = 0.5

var _moving: bool = false
var _last_motion_vector: Vector2 = Vector2.ZERO
var _alternate_y_leg_animation: bool = true
var _input_vector_dict = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}
var _frozen: bool = false
var _forced_position = null

onready var _tween: Tween = $Tween
onready var _animated_sprite: AnimatedSprite = $AnimatedSprite
onready var _message_box: CanvasLayer = $Camera2D/MessageBox
onready var _raycast: RayCast2D = $RayCast2D

func _ready():
	self._tween.connect("tween_started", self, "_on_tween_started")
	self._tween.connect("tween_completed", self, "_on_tween_completed")
	
func _process_movement():
	if ! self._moving:

		var motion_vector = Vector2.ZERO
		var animation_name
		
		# get direction pressed
		for action in self._input_vector_dict:
			if Input.is_action_pressed(action):
				motion_vector += self._input_vector_dict[action]
			
		# work out animation based on direction pressed
		match(motion_vector):
			Vector2.UP:
				animation_name = "Walk Up"
			Vector2.DOWN:
				animation_name = "Walk Down"
			Vector2.LEFT:
				animation_name = "Walk Left"
			Vector2.RIGHT:
				animation_name = "Walk Right"
		
		# play frame 1, which simulates idle
		if animation_name:
			self._animated_sprite.play(animation_name)
			self._animated_sprite.stop()

		# if we've moved, test we can move to target position
		if motion_vector:
			self._last_motion_vector = motion_vector

			# update raycast for interactables
			self._raycast.set_cast_to(motion_vector * self.TILE_SIZE)
			self._raycast.force_raycast_update()

			if not test_move(self.global_transform, motion_vector):

				# if we can, tween the position over .5s
				self._tween.interpolate_property( 
					self, 
					'position', position, position + (motion_vector * TILE_SIZE), 
					.5, 
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
				)
				self._tween.start()

				# the y anim need to alternate 
				# walk down and walk down 2; left foot, right foot
				if self._alternate_y_leg_animation and motion_vector.y != 0:
					animation_name = animation_name + " 2"
				
				self._alternate_y_leg_animation = ! self._alternate_y_leg_animation
				self._animated_sprite.play(animation_name)

func _physics_process(_delta):
	if get_frozen():
		return

	self._process_movement()
	self._process_interactables()
	
func _process_interactables():
	if Input.is_action_just_pressed("ui_accept"):
		self._raycast.force_raycast_update()
		if self._raycast.is_colliding():
			var collided_with = self._raycast.get_collider().get_parent()

			if collided_with.is_in_group("sign"):
				collided_with.interact()

func set_frozen(value):
	self._frozen = value

func get_frozen():
	return self._frozen

func _on_tween_started(_object, _key):
	self._moving = true
	
	if self._forced_position:
		self._tween.stop_all()
		self.censor_camera()
	
func _on_tween_completed(_object, _key):
	self.stop_moving()
	
func stop_moving():
	self._moving = false
	self._animated_sprite.stop()
	self._animated_sprite.set_frame(0)
	
func censor_camera():
	$Camera2D/ColorRect.visible = true
	
func stop_censor_camera():
	$Camera2D/ColorRect.visible = false
