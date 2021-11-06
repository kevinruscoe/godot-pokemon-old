extends KinematicBody2D

const TILE_SIZE: int = 32

export var speed: float = 0.5

var _is_moving: bool = false
var _is_frozen: bool = false
var _last_motion_vector: Vector2 = Vector2.DOWN
var _alternate_y_leg_animation: bool = true
var _input_vector_dict = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

onready var _tween: Tween = $Tween
onready var _animated_sprite: AnimatedSprite = $AnimatedSprite
onready var _raycast: RayCast2D = $RayCast2D

signal moving_started
signal moving_completed
signal has_frozen
signal has_unfrozen

func _ready():
	self._tween.connect("tween_started", self, "_on_tween_started")
	self._tween.connect("tween_completed", self, "_on_tween_completed")
	
func _get_input_vector() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	
	for action in self._input_vector_dict:
		if Input.is_action_pressed(action):
			input_vector = self._input_vector_dict[action]
			self._update_idle_state(input_vector)

	return input_vector
	
func _update_idle_state(vector: Vector2):
	self._last_motion_vector = vector
	
	match self._last_motion_vector:
		Vector2.UP:
			self._animated_sprite.play("Idle Up")
		Vector2.RIGHT:
			self._animated_sprite.play("Idle Right")
		Vector2.DOWN:
			self._animated_sprite.play("Idle Down")
		Vector2.LEFT:
			self._animated_sprite.play("Idle Left")

func _process_movement():
	if self.get_is_moving():
		return
		
	var input_vector = self._get_input_vector()
	var target_position = self.position + input_vector * self.TILE_SIZE

	if input_vector and not test_move(self.global_transform, input_vector):
		self._tween.interpolate_property( 
			self, 
			'position', position, target_position,
			.5, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		self._tween.start()

func _physics_process(_delta):
	if self.get_is_frozen():
		return
		
	self._update_raycast()

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

func _update_raycast():
	var line: Line2D = get_node("/root/Game/Line2D")
	line.clear_points()
	line.add_point(self.global_position + Vector2(16,16))
	line.add_point(self.global_position + Vector2(16,16) + (self._last_motion_vector * self.TILE_SIZE))
	self._raycast.set_cast_to(self._last_motion_vector * self.TILE_SIZE)

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
	
func _on_tween_started(object, key):
	if object == self and key == ":position":
		self.set_is_moving(true)
		
		match self._get_input_vector():
			Vector2.UP:
				var animation_name = "Walk Up"
				if self._alternate_y_leg_animation:
					animation_name += " 2"
				self._animated_sprite.play(animation_name)
				self._alternate_y_leg_animation = !self._alternate_y_leg_animation
			Vector2.RIGHT:
				self._animated_sprite.play("Walk Right")
			Vector2.DOWN:
				var animation_name = "Walk Down"
				if self._alternate_y_leg_animation:
					animation_name += " 2"
				self._animated_sprite.play(animation_name)
				self._alternate_y_leg_animation = !self._alternate_y_leg_animation
			Vector2.LEFT:
				self._animated_sprite.play("Walk Left")
	
func _on_tween_completed(object, key):
	if object == self and key == ":position":
		self.reset_movement()
		
func reset_movement():
	self._tween.stop_all()
	self.set_is_moving(false)
	self._update_idle_state(self._last_motion_vector)
