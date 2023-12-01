extends Node2D
class_name Grapple

enum State {IDLE, EXTENDING, HOOKED, RETRACTING}

@export var shoot_grapple_sound : AudioStream
#@export var ding_grapple_sound : AudioStream

@export var input_enabled := true
@export var speed := 50.0
@export var grapple_length := 5.0
@export var _can_grapple := true

var _pointQueryParams := PhysicsPointQueryParameters2D.new()
var _state := State.IDLE :
	set(val):
		visible = val != State.IDLE
		_state = val
		if val == State.IDLE:
			_can_grapple = false
			get_tree().create_timer(0.1).timeout.connect(func(): _can_grapple = true)
		#elif val == State.HOOKED:
			#SoundController.play(ding_grapple_sound, -15, randf_range(0.4, 0.6))
			
var _target := Vector2.ZERO
var _is_target_grappable := false

@onready var hook := $Hook as CharacterBody2D
@onready var hook_raycast := $Hook/RayCast2D as RayCast2D
@onready var chain := $Chain as Line2D


func _ready() -> void:
	_pointQueryParams.collide_with_areas = true
	_pointQueryParams.collide_with_bodies = false
	_pointQueryParams.collision_mask = 4 # Grappleable areas are on Layer 3, Bit 2 (zero-indexed).
	hook.top_level = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grapple") and _state == State.IDLE and input_enabled and _can_grapple:
		_set_target()
		SoundController.play(shoot_grapple_sound, -8, randf_range(1.0, 1.2))
		_state = State.EXTENDING
		hook.global_position = global_position
		
	elif event.is_action_released("grapple") and _state != State.IDLE:
		_state = State.IDLE


func _physics_process(delta: float) -> void:
	match _state: 
		State.IDLE:
			return
		State.EXTENDING:
			_extend_process(delta)
		State.HOOKED:
			_hooked_process(delta)
		State.RETRACTING:
			_retract_process(delta)


func _extend_process(delta: float) -> void:	
	
	var motion := hook.global_position.direction_to(_target) * speed * delta * GameConsts.PIXELS_PER_UNIT
	var length_traveled := hook.global_position.distance_to(global_position)
	
	# Make sure to cap the length of the grapple.
	if length_traveled + motion.length() > grapple_length * GameConsts.PIXELS_PER_UNIT:
		# if the hook does not catch anything this update, it will be retracting on the next one.
		_state = State.RETRACTING
		# cap the motion this update to not overshoot.
		motion = hook.global_position.direction_to(_target) * (grapple_length * GameConsts.PIXELS_PER_UNIT - length_traveled)
	
	# Rotate the hook accordingly. This must happen before raycasting, as the raycast direction is
	# forward relative to the hook's rotation.
	hook.look_at(_target)
	
	# Raycast to the new position.
	hook_raycast.target_position = Vector2.RIGHT * motion.length()
	hook_raycast.force_raycast_update()
	if hook_raycast.is_colliding():
		if hook_raycast.get_collider() is GrappleArea:
			var grapple_area := hook_raycast.get_collider() as GrappleArea
			# Hit a grappleable.
			hook.global_position = grapple_area.get_grapple_point(hook_raycast.get_collision_point())
			_state = State.HOOKED if grapple_area.is_hookable else State.RETRACTING
		
		else:
			# Hit a wall.
			hook.global_position = hook_raycast.get_collision_point()
			_state = State.RETRACTING
	else:
		# Nothing impeding the hook.
		if motion.length() > hook.global_position.distance_to(_target):
			hook.global_position = _target
			_state = State.RETRACTING
		else:
			hook.global_position += motion
	
	# Update chain.
	chain.set_point_position(0, to_local(hook.global_position))

func _hooked_process(_delta: float) -> void:
	# Rotate hook accordingly.
	hook.look_at(global_position)
	hook.rotation_degrees += 180
	
	# Update chain.
	chain.set_point_position(0, to_local(hook.global_position))


func _retract_process(delta: float) -> void:
	# Move the hook's position.
	var motion := hook.global_position.direction_to(global_position) * speed * delta * GameConsts.PIXELS_PER_UNIT
	if motion.length() > hook.global_position.distance_to(global_position):
		hook.global_position = global_position
		_state = State.IDLE
	else:
		hook.global_position += motion
	
	# Rotate the hook accordingly.
	hook.look_at(global_position)
	hook.rotation_degrees += 180
	
	# Update chain.
	chain.set_point_position(0, to_local(hook.global_position))


func _set_target() -> void:
	var mouse_pos := get_global_mouse_position()
	var grapple_area := _get_grapple_area(mouse_pos)
	if grapple_area == null:
		_target = mouse_pos
		_is_target_grappable = false
	else:
		_target = grapple_area.get_grapple_point(mouse_pos)
		_is_target_grappable = true


func _get_grapple_area(at_position: Vector2) -> GrappleArea:
	_pointQueryParams.position = at_position
	var result := get_world_2d().direct_space_state.intersect_point(_pointQueryParams, 1)
	if result.is_empty():
		return null
	return result.front().get("collider") as GrappleArea


func is_hooked() -> bool:
	return _state == State.HOOKED


func unhook() -> void:
	_state = State.RETRACTING
	

func get_current_chain_length() -> float:
	return global_position.distance_to(hook.global_position)


func get_direction() -> Vector2:
	return global_position.direction_to(hook.global_position)
