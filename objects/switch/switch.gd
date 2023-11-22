extends Powerable
class_name Switch

@onready var _sprite := $Sprite as AnimatedSprite2D

func _ready() -> void:
	super()
	_sprite.animation = "to_on" if _is_powered else "to_off"
	_sprite.frame = 1
	($GrappleArea as Area2D).body_entered.connect(_on_grappled)


func _on_grappled(_body: Node2D) -> void:
	# This is nearly identical to the Powerable's _on_change() function, except that it does not
	# not check the origin source to break out early, because this is the start of a signal chain.
	_is_powered = !_is_powered
	if _signal_delay > 0:
		get_tree().create_timer(_signal_delay).timeout.connect(func(): changed.emit(_is_powered, self))
	else:
		changed.emit(_is_powered, self)
	_change()
	

func _change() -> void:
	_sprite.play("to_on" if _is_powered else "to_off")
