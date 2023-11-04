extends CharacterBody2D
class_name PlayerMovement

enum State {FREE, GRAPPLED}

@export var input_enabled := true

@export_category("Platforming Parameters")
@export var _run_speed := 7.0
@export var _time_to_run_speed := 0.1
@export var _jump_height := 1.5
@export var _jump_distance := 1.5
@export var _jump_min_height :=  0.5
@export var _fall_distance := 1.2

@export_category("Grappling Parameters")
@export var grapple_enabled := true
@export var _grapple_speed := 40.0
@export var _time_to_grapple_speed := 0.2
@export var _post_grapple_velocity := Vector2.UP * 15 * GameConsts.PIXELS_PER_UNIT

var _state := State.FREE
var _grapple_point: Vector2
var _current_grapple_speed: float

# TODO: I don't think these need to be @onready
@onready var _acceleration := (_run_speed / _time_to_run_speed) if _time_to_run_speed > 0 else -1.0
@onready var _jump_speed := 2 * _jump_height * _run_speed / _jump_distance
@onready var _jump_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_jump_distance, 2)
@onready var _jump_min_gravity := pow(_jump_speed, 2) / (2 * _jump_min_height)
@onready var _fall_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_fall_distance, 2)
@onready var _current_gravity := _jump_gravity
@onready var _grapple_acceleration := (_grapple_speed / _time_to_grapple_speed) if _time_to_grapple_speed > 0 else -1.0

@onready var _jump_buffer_timer := $JumpBufferTimer as Timer
@onready var _coyote_timer := $CoyoteTimer as Timer

func _physics_process(delta: float) -> void:
	# Read input from the player.
	var input := _read_input() if input_enabled else {}
	
	match _state:
		State.FREE:
			_free_physics_process(delta, input)
		State.GRAPPLED:
			_grappled_physics_process(delta, input)


func _free_physics_process(delta: float, input: Dictionary) -> void:
	
	# If the player grapples, switch states.
	if grapple_enabled and input.get("grapple_pressed", false):
		_transition_state_from_free_to_grappled(input.get("grapple_point"))
		return
		
	# Register jumps in the jump buffer.
	_update_jump_buffer(input.get("jump_pressed", false))
	
	# Handle vertical movement.
	if _can_jump():
		_jump()
	else:
		_apply_gravity(input.get("jump_released", false), delta)
	
	# Handle horizontal movement.
	_run(input.get("h_axis", 0), delta)
	
	# Move the Player.
	move_and_slide()
	
	# Keep track of coyote time.
	_update_coyote_timer()


func _grappled_physics_process(delta: float, input: Dictionary) -> void:
	# TODO: Transition back to free should retain previous velocity (cache it somewhere) if the
	#   grapple fails.
	
	_current_grapple_speed = min(_current_grapple_speed + _grapple_acceleration * delta, _grapple_speed)
	velocity = position.direction_to(_grapple_point) * _current_grapple_speed * GameConsts.PIXELS_PER_UNIT
	
	if _can_reach_target_this_frame(delta, _grapple_point):
		_transition_state_from_grappled_to_free(true)
		return
	elif input.get("grapple_released", false):
		_transition_state_from_grappled_to_free(false)
		return
	
	move_and_slide()


func _transition_state_from_free_to_grappled(new_grapple_point: Vector2) -> void:
	velocity = Vector2.ZERO
	_grapple_point = new_grapple_point
	_current_grapple_speed = 0
	_state = State.GRAPPLED
	
func _transition_state_from_grappled_to_free(reached_grapple_point: bool) -> void:
	if reached_grapple_point:
		position = _grapple_point 
		velocity = _post_grapple_velocity
	_state = State.FREE
	

# Reads the player's input and packages it up into a dictionary for use in this frame.
func _read_input() -> Dictionary:
	return {
		"h_axis": Input.get_axis("left", "right"),
		"jump_pressed": Input.is_action_just_pressed("jump"),
		"jump_released": Input.is_action_just_released("jump"),
		"grapple_pressed": Input.is_action_just_pressed("grapple"),
		"grapple_released": Input.is_action_just_released("grapple"),
		"grapple_point": get_global_mouse_position(),
	}


func _run(h_axis: float, delta: float) -> void:
	var target_x := h_axis * _run_speed * GameConsts.PIXELS_PER_UNIT
	if _time_to_run_speed <= 0:
		velocity.x = target_x
	else:
		velocity.x = move_toward(
				velocity.x, 
				target_x, 
				_acceleration * delta * GameConsts.PIXELS_PER_UNIT
		)


func _update_jump_buffer(input_jump_pressed: bool) -> void:
	if input_jump_pressed:
		_jump_buffer_timer.start()


func _can_jump() -> bool:
	return !_coyote_timer.is_stopped() and !_jump_buffer_timer.is_stopped()


func _jump() -> void:
	_jump_buffer_timer.stop()
	_coyote_timer.stop()
	_current_gravity = _jump_gravity
	velocity.y = -_jump_speed * GameConsts.PIXELS_PER_UNIT


func _apply_gravity(input_jump_released: bool, delta: float) -> void:
	if velocity.y > 0:
			_current_gravity = _fall_gravity 
	elif input_jump_released:
		_current_gravity = _jump_min_gravity
	velocity.y += _current_gravity * delta * GameConsts.PIXELS_PER_UNIT


func _update_coyote_timer() -> void:
	if is_on_floor():
		_coyote_timer.start()


func _can_reach_target_this_frame(delta:float, target: Vector2) -> bool:
	# Note that this an oversimplification: It ignores the velocity's direction.
	return position.distance_to(target) < velocity.length() * delta
