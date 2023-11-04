extends Node
class_name StateMachine

@export var _initial_state := NodePath()

var _state: PlayerState

func _ready() -> void:
	_state = get_node(_initial_state)
	_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	_state.handle_input(event)


func _process(delta: float) -> void:
	_state.update(delta)


func _physics_process(delta: float) -> void:
	_state.physics_update(delta)


func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	var target_state_node_name = target_state_name.capitalize()
	if not has_node(target_state_node_name):
		push_error(
				"(%s) Could not transition to state %s. "
				+ "It does not exist as a child of the StateMachine"
				% [get_path(), target_state_name]
		)
		return

	_state.exit()
	_state = get_node(target_state_node_name)
	_state.enter(msg)


func has_state(target_state_name: String) -> bool:
	return has_node(target_state_name.capitalize())
