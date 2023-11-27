extends CanvasLayer

func _ready() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($VBoxContainer, "modulate", Color.TRANSPARENT, 0.5).set_delay(3)
	tween.tween_callback(func(): queue_free())
