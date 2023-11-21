extends Node2D
class_name GrappleOld

signal extended(is_attached)
signal pulled

enum State {IDLE, EXTENDING, EXTENDED, RETRACTING, PULLING}

@export var _grapple_speed := 60.0
@export var _input_enabled = true
@export var _grapple_length := 5.0

var target: Vector2
var _state := State.IDLE
var _grapple_total_time: float
var _grapple_time: float
var _can_attach: bool

@onready var _chain := $Chain as Line2D
@onready var _hook := $Hook as Sprite2D
@onready var _raycast := $RayCast2D as RayCast2D

func _unhandled_input(event):
	if event.is_action_pressed("grapple") and _state == State.IDLE:
		extend(get_global_mouse_position())
		pass
	elif event.is_action_released("grapple") and (_state == State.EXTENDING or _state == State.EXTENDED):
		print("retract")
		# Retract
		pass 
		
	

func extend(to: Vector2) -> void:
	_cast_ray(to)
	_state = State.EXTENDING
	_grapple_total_time = global_position.distance_to(target) / GameConsts.PIXELS_PER_UNIT / _grapple_speed
	_grapple_time = 0
	visible = true
	

func retract() -> void:
	if _state != State.IDLE or _state != State.RETRACTING:
		_state = State.RETRACTING
		_grapple_total_time = global_position.distance_to(target) / GameConsts.PIXELS_PER_UNIT / _grapple_speed
		_grapple_time = _grapple_total_time 

func pull() -> void:
	if _state != State.IDLE:
		_state = State.PULLING
func is_ready() -> bool:
	return _state == State.IDLE

func _physics_process(delta: float) -> void:
	match _state:
		State.IDLE:
			pass

		State.PULLING:
			_set_grapple_head(target)
			if target == global_position:
				_state = State.IDLE
				visible = false
				pulled.emit()

		State.EXTENDING:
			_grapple_time = min(_grapple_time + delta, _grapple_total_time)
			var current_position := global_position.lerp(target, _grapple_time/_grapple_total_time)
			_set_grapple_head(current_position)
			if _grapple_time == _grapple_total_time:
				_state = State.EXTENDED
				extended.emit(_can_attach)

		State.EXTENDED:
			_set_grapple_head(target)

		State.RETRACTING:
			_grapple_time = max(0, _grapple_time - delta)
			if _grapple_time == 0:
				_state = State.IDLE
				visible = false
			_set_grapple_head(global_position.lerp(target, _grapple_time/_grapple_total_time))

func _cast_ray(to: Vector2):
	_raycast.enabled = true
	_raycast.target_position = to_local(position.direction_to(to) * _grapple_length)
	_raycast.force_raycast_update()
	
	if not _raycast.is_colliding():
		# If the grapple won't hit anything, extend it the full way, but don't attach.
		_can_attach = false
		target = to
	elif _raycast.get_collider() is GrappleArea:
		# If the grapple hits a grapple area, extend it to a grapple area's grapple point, attach.
		_can_attach = true
		target = (_raycast.get_collider() as GrappleArea).get_grapple_point(to)
	else:
		# if the grapple hits a wall, extend to the wall, but don't attach.
		_can_attach = false
		target = _raycast.get_collision_point()
	_raycast.target_position = Vector2.ZERO
	_raycast.enabled = false
	

func _set_grapple_head(pos: Vector2) -> void:
	pass
#	set_point_position(1, to_local(pos))
