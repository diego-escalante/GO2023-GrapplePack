extends Powerable

@export var _dialogue: Array[Dialogue] = []

@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _static_body := $StaticBody2D as StaticBody2D
@onready var _area := $Area2D as Area2D

var _is_player_inside := false

func _ready() -> void:
	super()
	_sprite.frame = 3 if _is_powered else 0
	_static_body.set_collision_layer_value(1, _is_powered)
	_area.body_entered.connect(_on_player_entered)
	_area.body_exited.connect(_on_player_exit)

	
func _change() -> void:
	if not _is_player_inside:
		_sprite.play("default", 1 if _is_powered else -1)
		_static_body.set_collision_layer_value(1, _is_powered)
	else:
		DialogueController.queue_up(_dialogue)


func _on_player_entered(_body: Node2D) -> void:
	_is_player_inside = true

	
func _on_player_exit(_body: Node2D) -> void:
	if _is_player_inside:
		_is_player_inside = false
		_change()
