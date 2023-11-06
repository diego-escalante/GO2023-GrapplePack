extends Node
class_name PlayerState

var state_machine: StateMachine
var player: Player
var grapple: Grapple

func _ready() -> void:
	var parent = get_parent()
	if not parent is StateMachine:
		push_error(
				"(%s) PlayerState not a child of a StateMachine and will be deleted." 
				% get_path()
		)
		queue_free()
		return
	if not owner is Player:
		push_error(
				"(%s) PlayerState's owner is not a Player and will be deleted."
				% get_path()
		)
		queue_free()
		return
	player = owner
	grapple = player.get_node("Grapple")
	state_machine = parent


# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
