extends CharacterBody2D
class_name Player

signal just_grounded

@export var _input_enabled := true
@export var _grapple_enabled := true
@export var freeze_position := false

@export var _run_speed := 7.0
@export var _time_to_run_speed := 0.1
@export var _jump_height := 1.5
@export var _jump_distance := 1.5
@export var _jump_min_height := 0.5
@export var _fall_distance := 1.2
@export var _terminal_velocity := 14.0
@export var _grapple_pull_speed := 10.0
@export var _grapple_time_to_pull_speed := 0.3

@onready var _acceleration := (_run_speed / _time_to_run_speed) if _time_to_run_speed > 0 else -1.0
@onready var _jump_speed := 2 * _jump_height * _run_speed / _jump_distance
@onready var _jump_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_jump_distance, 2)
@onready var _jump_min_gravity := pow(_jump_speed, 2) / (2 * _jump_min_height)
@onready var _fall_gravity := 2 * _jump_height * pow(_run_speed, 2) / pow(_fall_distance, 2)
@onready var _current_gravity := _jump_gravity
@onready var _grapple_acceleration := (_grapple_pull_speed / _grapple_time_to_pull_speed) if _grapple_pull_speed > 0 else -1.0

var _prev_is_on_floor := true
var _grapple_current_speed := 0.0

@onready var _jump_buffer_timer := $JumpBufferTimer as Timer
@onready var _coyote_timer := $CoyoteTimer as Timer
@onready var _drop_timer := $DropTimer as Timer
@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _grapple := $Grapple as Grapple
@onready var _hitbox := $Hitbox as Area2D

func _ready() -> void:
	# Reset one-way platform collisions each time the _drop_timer finishes.
	_drop_timer.timeout.connect(func(): set_collision_mask_value(4, true))
	_hitbox.body_entered.connect(_on_hit)
	set_input_enabled(_input_enabled, _grapple_enabled)


func _physics_process(delta: float) -> void:
	if freeze_position:
		return
	
	# Grappled Physics
	if _grapple.is_hooked():
		_grapple_current_speed = min(_grapple_current_speed + _grapple_acceleration * delta, _grapple_pull_speed)
		velocity = _grapple.get_direction() * _grapple_current_speed * GameConsts.PIXELS_PER_UNIT
		if velocity.length() * delta > _grapple.get_current_chain_length():
			_grapple.unhook()
			_grapple_current_speed = 0
			_current_gravity = _jump_gravity
		_sprite.animation = "jump" if velocity.y < 0 else "fall"
		move_and_slide()
		return
		
	# Normal Physics
	_grapple_current_speed = 0
	
	# Read input from the player.
	var input := _read_input() if _input_enabled else {}
		
	# Register jumps in the jump buffer.
	_update_jump_buffer(input.get("jump_pressed", false))
	
	# Handle horizontal movement.
	velocity.x = _calculate_run_velocity(velocity.x, input.get("h_axis", 0), delta)
	
	# Handle vertical movement.
	if _can_jump() and not input.get("down_held", false):
		# Perform jump.
		_jump_buffer_timer.stop()
		_coyote_timer.stop()
		_current_gravity = _jump_gravity
		velocity.y = -_jump_speed * GameConsts.PIXELS_PER_UNIT
	else:
		# Apply gravity.
		if velocity.y > 0:
			_current_gravity = _fall_gravity
		elif input.get("jump_released", false):
			_current_gravity = _jump_min_gravity
		velocity.y = min(velocity.y + _current_gravity * delta * GameConsts.PIXELS_PER_UNIT, _terminal_velocity * GameConsts.PIXELS_PER_UNIT)
	
	# Drop.
	if input.get("down_held", false) and input.get("jump_pressed", false):
		set_collision_mask_value(4, false)
		_jump_buffer_timer.stop()
		_drop_timer.start()
	
	# Keep track of coyote time.
	if is_on_floor():
		_coyote_timer.start()
	
	update_animation(input.get("down_held", false))
	
	if not _prev_is_on_floor and is_on_floor():
		just_grounded.emit()
		
	_prev_is_on_floor = is_on_floor()
	
	move_and_slide()


func exit() -> void:
	_coyote_timer.stop()
	_jump_buffer_timer.stop()
	

func update_animation(is_down_held: bool) -> void:

	
	# Flip player accordingly.
	if velocity.x != 0:
		_sprite.flip_h = velocity.x < 0
	
	# Player just ungrounded.
	if _prev_is_on_floor and not is_on_floor():
		_sprite.play("jump" if velocity.y < 0 else "fall")
		return
	
	# Player just grounded.
	if not _prev_is_on_floor and is_on_floor():
		_sprite.play("land" if not is_down_held else "crouch")
		return
	
	match _sprite.animation:
		"land":
			if not _sprite.is_playing():
				_sprite.play("idle")
		"jump":
			if velocity.y > 0:
				_sprite.play("fall")
		"idle":
			if velocity.x != 0:
				_sprite.play("walk")
			elif is_down_held:
				_sprite.play("crouch")
		"walk":
			if velocity.x == 0:
				_sprite.play("idle")
		"crouch":
			if velocity.x != 0 or not is_down_held:
				_sprite.play("idle")
	

# Reads the player's input and packages it up into a dictionary for use in this frame.
func _read_input() -> Dictionary:
	return {
		"h_axis": Input.get_axis("left", "right"),
		"down_held": Input.is_action_pressed("down"),
		"jump_pressed": Input.is_action_just_pressed("jump"),
		"jump_released": Input.is_action_just_released("jump"),
	}
	

func _update_jump_buffer(input_jump_pressed: bool) -> void:
	if input_jump_pressed:
		_jump_buffer_timer.start()


func _can_jump() -> bool:
	return !_coyote_timer.is_stopped() and !_jump_buffer_timer.is_stopped()

	
func _calculate_run_velocity(velocity_x: float, h_axis: float, delta: float) -> float:
	var target_x := h_axis * _run_speed * GameConsts.PIXELS_PER_UNIT
	if _time_to_run_speed <= 0:
		return target_x
	else:
		return move_toward(
				velocity_x, 
				target_x, 
				_acceleration * delta * GameConsts.PIXELS_PER_UNIT
		)

func _on_hit(_body: Node2D) -> void:
	owner.respawn()


func set_input_enabled(movement: bool, grapple: bool) -> void:
	_input_enabled = movement
	_grapple.input_enabled = grapple
	var old_sprite := _sprite
	_sprite = $AnimatedSprite2D if grapple else $AnimatedSprite2DNoGrapple 
	if old_sprite != null:
		old_sprite.visible = false
		_sprite.animation = old_sprite.animation
		_sprite.frame = old_sprite.frame
		_sprite.flip_h = old_sprite.flip_h
	_sprite.visible = true
