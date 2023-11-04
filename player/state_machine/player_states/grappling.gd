extends PlayerState
class_name Grappling

@export var _grapple_speed := 40.0
@export var _time_to_grapple_speed := 0.2
@export var _post_grapple_velocity := Vector2.UP * 15 * GameConsts.PIXELS_PER_UNIT

var _grapple_point: Vector2
var _current_grapple_speed: float
var _grapple_acceleration := (_grapple_speed / _time_to_grapple_speed) if _time_to_grapple_speed > 0 else -1.0


func enter(msg := {}):
	if msg.has("grapple_point"):
		_grapple_point = msg.get("grapple_point")
	else:
		push_error("Entered grappling state without a grapple_point.")
		_grapple_point = player.position
	_current_grapple_speed = 0


func physics_update(delta: float) -> void:
	# Read input from the player.
	var input := _read_input() if player.input_enabled else {}
	
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
	elif input.get("grapple_released", false):
		state_machine.transition_to("platforming")
		return


# Reads the player's input and packages it up into a dictionary for use in this frame.
func _read_input() -> Dictionary:
	return {
		"h_axis": Input.get_axis("left", "right"),
		"jump_pressed": Input.is_action_just_pressed("jump"),
		"jump_released": Input.is_action_just_released("jump"),
		"grapple_pressed": Input.is_action_just_pressed("grapple"),
		"grapple_released": Input.is_action_just_released("grapple")
	}
	
func _can_reach_target_this_frame(delta:float, target: Vector2) -> bool:
	# Note that this an oversimplification: It ignores the velocity's direction.
	return player.position.distance_to(target) < player.velocity.length() * delta
