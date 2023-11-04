extends PlayerState
class_name Grappled

@export var _grapple_speed := 40.0
@export var _time_to_grapple_speed := 0.2
@export var _post_grapple_velocity := Vector2.UP * 15 * GameConsts.PIXELS_PER_UNIT

var _grapple_point: Vector2
var _current_grapple_speed: float
var _grapple_acceleration := (_grapple_speed / _time_to_grapple_speed) if _time_to_grapple_speed > 0 else -1.0


func enter(msg := {}) -> void:
	player.velocity = Vector2.ZERO
	if msg.has("grapple_point"):
		_grapple_point = msg.get("grapple_point")
	else:
		push_error("Entered grappling state without a grapple_point.")
		_grapple_point = player.position
	_current_grapple_speed = 0


func physics_update(delta: float) -> void:
	# TODO: Transition back to free should retain previous velocity (cache it somewhere) if the
	#   grapple fails.
	_current_grapple_speed = min(_current_grapple_speed + _grapple_acceleration * delta, _grapple_speed)
	player.velocity = player.position.direction_to(_grapple_point) * _current_grapple_speed * GameConsts.PIXELS_PER_UNIT
	
	# If the player can reach the target this frame. (Oversimplified: ignores velocity's direction.)
	if _can_reach_target_this_frame(delta, _grapple_point):
		player.position = _grapple_point 
		player.velocity = _post_grapple_velocity
		state_machine.transition_to("platforming")
		return
	elif player.input_enabled and Input.is_action_just_released("grapple"):
		state_machine.transition_to("platforming")
		return
	
func _can_reach_target_this_frame(delta:float, target: Vector2) -> bool:
	# Note that this an oversimplification: It ignores the velocity's direction.
	return player.position.distance_to(target) < player.velocity.length() * delta
