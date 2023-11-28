extends CanvasLayer

@onready var _player := get_tree().get_first_node_in_group("player") as Node2D

var _once := true

func _physics_process(_delta: float) -> void:
	if (_player.global_position.y <= -490 or _player.global_position.y > -360) and _once:
		_once = false
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property($VBoxContainer, "modulate", Color.TRANSPARENT, 0.2)
		tween.tween_callback(func(): queue_free())
