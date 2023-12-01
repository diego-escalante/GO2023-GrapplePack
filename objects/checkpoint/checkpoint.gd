extends AnimatedSprite2D
class_name Checkpoint

@export var sound : AudioStream

@onready var _area := $Area2D as Area2D
@onready var _timer := $GlitchTimer as Timer
var _is_on := false

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	_area.body_entered.connect(_on_body_entered)
	_timer.timeout.connect(_on_timeout)
	_timer.start(randi_range(10, 20))
	

func _on_body_entered(_body: Node2D) -> void:
	if not _is_on:
		get_tree().call_group("checkpoint", "turn_off")
		_is_on = true
		GameState.set_checkpoint(self, sound)
		play("on")

	
func turn_off() -> void:
	if _is_on:
		_is_on = false
		play("off")
	
func _on_animation_finished() -> void:
	if animation == "glitch":
		play("on" if _is_on else "off")


func _on_timeout() -> void:
	if animation == "on":
		play("glitch")
	_timer.start(randi_range(10, 20))
