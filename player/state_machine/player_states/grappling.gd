extends PlayerState
class_name Grappling

var _grapple_point: Vector2
var _can_attach: bool

func enter(_msg := {}) -> void:
	_initialize_grapple()
	if _can_attach:
		state_machine.transition_to("grappled", {"grapple_point": _grapple_point})
	else:
		state_machine.transition_to("platforming")
	

func _initialize_grapple() -> void:
	_grapple_point = player.get_global_mouse_position()
	_can_attach = true
