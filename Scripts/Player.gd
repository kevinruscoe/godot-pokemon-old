extends KinematicBody2D

const TILE_SIZE: int = 32

export var speed: float = 0.5

var _is_moving: bool = false
var _is_frozen: bool = false
var _last_motion_vector: Vector2 = Vector2.ZERO
var _alternate_y_leg_animation: bool = true
var _input_vector_dict = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

var _tween: Tween
var _animated_sprite: AnimatedSprite
var _sprite: Sprite
var _raycast: RayCast2D
var _animation_tree: AnimationTree
var _animation_player: AnimationPlayer

signal moving_started
signal moving_completed
signal has_frozen
signal has_unfrozen

func _enter_tree():
	self._tween = self.get_node("Tween")
	self._animated_sprite = self.get_node("AnimatedSprite")
	self._raycast = self.get_node("RayCast2D")
	
	self._tween.connect("tween_started", self, "_on_tween_started")
	self._tween.connect("tween_completed", self, "_on_tween_completed")

func _ready():
	pass
	
func _process_movement():
	if self.get_is_frozen():
		return
		
	if ! self.get_is_moving():

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

			var line = get_node("/root/Game/Line2D")
			line.clear_points()
			line.add_point(self.global_transform)
			line.add_point( (self.global_transform) + motion_vector * 32 )

			# update raycast for interactables
			self._raycast.set_cast_to(motion_vector * 32)
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
	if self._is_frozen:
		return

	self._process_movement()
	self._process_interactables()
	
func _process_interactables():
	self._raycast.force_raycast_update()
	
	if self._raycast.is_colliding():
		var collided_with = self._raycast.get_collider().get_parent()

		if collided_with.is_in_group("spawn_point"):
			collided_with.transition()
			
		if collided_with.is_in_group("sign") and Input.is_action_just_pressed("ui_accept"):
			collided_with.interact()

func set_is_frozen(value):
	self._is_frozen = value
	
	if self._is_frozen:
		emit_signal("has_frozen")
	else:
		emit_signal("has_unfrozen")
	
func get_is_frozen():
	return self._is_frozen
	
func set_is_moving(value):
	self._is_moving = value
	
	if self._is_moving:
		emit_signal("moving_started")
	else:
		emit_signal("moving_completed")
	
func get_is_moving():
	return self._is_moving
	
func _on_tween_started(_object, _key):
	self.set_is_moving(true)
	
func _on_tween_completed(_object, _key):
	self.set_is_moving(false)
	# mark as idle
	self._animated_sprite.stop()
	self._animated_sprite.set_frame(0)
