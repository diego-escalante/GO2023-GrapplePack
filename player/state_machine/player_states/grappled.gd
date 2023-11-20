extends PlayerState
class_name Grappled

@export var _grapple_speed := 40.0
@export var _time_to_grapple_speed := 0.5
@export var _post_grapple_velocity := Vector2.UP * 15 * GameConsts.PIXELS_PER_UNIT

var _grapple_point: Vector2
var _current_grapple_speed: float
var _grapple_acceleration := (_grapple_speed / _time_to_grapple_speed) if _time_to_grapple_speed > 0 else -1.0

func enter(_msg := {}) -> void:
	player.velocity = Vector2.ZERO
	_grapple_point = grapple.target
	_current_grapple_speed = 0
	grapple.pull()


func physics_update(delta: float) -> void:
	
	_current_grapple_speed = min(_current_grapple_speed + _grapple_acceleration * delta, _grapple_speed)
	var grapple_velocity = player.position.direction_to(_grapple_point) * _current_grapple_speed * GameConsts.PIXELS_PER_UNIT
	
	player.velocity += grapple_velocity
	
	# If the player can reach the target this frame. (Oversimplified: ignores velocity's direction.)
	if player.position.distance_to(_grapple_point) < player.velocity.length() * delta:
		grapple.retract()
		player.position = _grapple_point 
		player.velocity = _post_grapple_velocity
		state_machine.transition_to("platforming")
		return
	elif player.input_enabled and Input.is_action_just_released("grapple"):
		grapple.retract()
		state_machine.transition_to("platforming")
		return
