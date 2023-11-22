extends Node
class_name Powerable

signal changed(is_powered: bool, origin: Powerable)

@export var _is_powered := false
@export var _upstream: Powerable
@export var _negate_upstream := false
@export var _signal_delay := 0.25


func _ready() -> void:
	# Do not forget to use super() when defining a _ready() function in a powerable.
	# Otherwise, the upstream powerable's signal will not be hooked up.
	if _upstream != null:
		_upstream.changed.connect(_on_changed)

func _on_changed(is_powered: bool, origin: Powerable) -> void:
	if origin == self:
		# Break out of cyclical chains
		return
	_is_powered = !is_powered if _negate_upstream else is_powered
	if _signal_delay > 0:
		get_tree().create_timer(_signal_delay).timeout.connect(func(): changed.emit(_is_powered, origin))
	else:
		changed.emit(_is_powered, origin)
	_change()
	

func _change() -> void:
	# To be overridden by Powerables.
	pass

