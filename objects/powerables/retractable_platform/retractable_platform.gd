extends Powerable

@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _static_body := $StaticBody2D as StaticBody2D

func _ready() -> void:
	super()
	_sprite.frame = 3 if _is_powered else 0
	_static_body.set_collision_layer_value(4, _is_powered)

	
func _change() -> void:
	_sprite.play("default", 1 if _is_powered else -1)
	_static_body.set_collision_layer_value(4, _is_powered)
