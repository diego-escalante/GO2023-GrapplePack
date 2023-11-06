extends Area2D
class_name GrappleArea

var collision_shape: CollisionShape2D

func _ready() -> void:
	var candidate := find_child("CollisionShape2D")
	if candidate is CollisionShape2D:
		collision_shape = candidate
	else:
		push_error("(%s) GrappleArea has no CollisionShape2D child, and will be deleted." % get_path())
		queue_free()
		return
	
	var shape := collision_shape.shape
	if shape == null:
		push_error("(%s) GrappleArea's CollisionShape2D has no shape attached to it, and will be deleted." % get_path())
		queue_free()
		return
		
	if not shape is CapsuleShape2D and not shape is CircleShape2D:
		push_error("(%s) GrappleArea's CollisionShape2D's shape is not a Capsule or a Circle, and will be deleted." % get_path())
		queue_free()


func get_grapple_point(mouse_position: Vector2) -> Vector2:
	var shape := collision_shape.shape
	var center := collision_shape.global_position
	
	# Grapple Area is a capsule, the grapple point is somewhere *in* the imaginary line in the 
	# center of the capsule.
	if shape is CapsuleShape2D:
		var capsule := shape as CapsuleShape2D
		var offset := Vector2(0, capsule.height / 2 - capsule.radius).rotated(collision_shape.global_rotation)
		var p1 = center - offset
		var p2 = center + offset
		return Geometry2D.get_closest_point_to_segment(mouse_position, p1, p2)
	
	# Grapple Area is a circle, the grapple point is the center.
	return center
