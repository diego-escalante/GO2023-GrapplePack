extends Powerable

@export var _hook_sound : AudioStream
@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _grapple_area := $GrappleArea as GrappleArea

func _ready() -> void:
	super()
	_sprite.frame = 2 if _is_powered else 0
	_grapple_area.set_collision_layer_value(3, _is_powered)
	_grapple_area.set_collision_mask_value(6, _is_powered)

	
func _change() -> void:
	SoundController.play(_hook_sound, -10, randf_range(0.9,1.1))
	_sprite.play("default", 1 if _is_powered else -1)
	_grapple_area.set_collision_layer_value(3, _is_powered)
	_grapple_area.set_collision_mask_value(6, _is_powered)
