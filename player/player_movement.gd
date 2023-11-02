extends CharacterBody2D
class_name PlayerMovement

@export var input_enabled := true

@export var _run_speed := 7.0
@export var _time_to_run_speed := 0.1
@export var _jump_height := 1.5
@export var _jump_distance := 1.5
@export var _jump_min_height :=  0.5
@export var _fall_distance := 1.2

@onready var _acceleration := (_run_speed / _time_to_run_speed) if _time_to_run_speed > 0 else -1.0
@onready var _jump_speed := 2 * _jump_height * _run_speed / _jump_distance
@onready var _jump_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_jump_distance, 2)
@onready var _jump_min_gravity := pow(_jump_speed, 2) / (2 * _jump_min_height)
@onready var _fall_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_fall_distance, 2)
@onready var _current_gravity := _jump_gravity

@onready var _jump_buffer_timer := $JumpBufferTimer as Timer
@onready var _coyote_timer := $CoyoteTimer as Timer

func _physics_process(delta: float) -> void:
	# Read input from the player.
	var input := _read_input() if input_enabled else {}
		
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


# Reads the player's input and packages it up into a dictionary for use in this frame.
func _read_input() -> Dictionary:
	return {
		"h_axis": Input.get_axis("left", "right"),
		"jump_pressed": Input.is_action_just_pressed("jump"),
		"jump_released": Input.is_action_just_released("jump"),
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
