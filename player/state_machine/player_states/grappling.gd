extends PlayerState
class_name Grappling

var _previous_velocity: Vector2

func enter(_msg := {}) -> void:
	grapple.extend(player.get_global_mouse_position())
	_previous_velocity = player.velocity
	player.velocity = Vector2.ZERO
	grapple.extended.connect(_on_grapple_extended)
	

func _on_grapple_extended(is_attached: bool) -> void:
	if is_attached:
		state_machine.transition_to("grappled")
	else:
		grapple.retract()
		state_machine.transition_to("platforming", {"initial_velocity": _previous_velocity})
		
func exit() -> void:
	grapple.extended.disconnect(_on_grapple_extended)
