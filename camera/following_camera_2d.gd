extends ShakingCamera2D
class_name FollowingCamera2D

@export var target: Node2D
@export var target_offset: Vector2
@export var follow_speed := 0.25
@export var y_movement_jump_lock := false

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	
	var new_position: Vector2
	if follow_speed <= 0:
		new_position = target.global_position + target_offset
	else:
		new_position = (
				global_position
				+ (target.global_position + target_offset - global_position) 
				* follow_speed * GameConsts.PIXELS_PER_UNIT 
				* delta
		)

	if y_movement_jump_lock:
		if not target is CharacterBody2D:
			push_warning(
					"FollowingCamera2D target is not a character body, " +
					"Y-movement jump lock will be disabled."
			)
			y_movement_jump_lock = false
		
		if not (target as CharacterBody2D).is_on_floor():
			new_position.y = global_position.y
	
	global_position = new_position
