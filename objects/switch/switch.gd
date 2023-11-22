extends Powerable
class_name Switch

@onready var _sprite := $Sprite as AnimatedSprite2D

func _ready() -> void:
	# Switches do not use upstream power signals. No need to use super() here.
	_sprite.animation = "to_on" if _is_powered else "to_off"
	_sprite.frame = 1
	($GrappleArea as Area2D).body_entered.connect(_on_grappled)


func _on_grappled(_body: Node2D) -> void:
	# Switches are special, they do not change via upstream signals, but by the grapple.
	_on_changed(!_is_powered)
	

func _change() -> void:
	_sprite.play("to_on" if _is_powered else "to_off")
