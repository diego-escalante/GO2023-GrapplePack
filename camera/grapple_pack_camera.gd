extends ShakingCamera2D
class_name GrapplePackCamera

func _process(delta: float) -> void:
	super(delta)
	if global_position.y < -8032:
		return
	if global_position.x > limit_right + 9:
		limit_right += 180 + 12
		limit_left += 180 + 12
	elif global_position.x < limit_left - 9:
		limit_right -= 180 + 12
		limit_left -= 180 + 12
