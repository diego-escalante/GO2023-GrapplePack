extends CanvasLayer

var _is_paused := false
var _tweening := false

@onready var _control := $Control

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause") and not _tweening:
		if not _is_paused and ScreenFade.is_faded():
			return
		
		_is_paused = not _is_paused
		
		_tweening = true
		if _is_paused:
			DialogueController.visible = false
			get_tree().paused = true
			_control.modulate = Color.TRANSPARENT
			visible = true
			ScreenFade.set_circle(0.075, 0.5)
			await ScreenFade.done
			var tween = create_tween()
			tween.tween_property(_control, "modulate", Color.WHITE, 0.25)
			tween.tween_callback(func(): _tweening = false)
		else:
			_control.modulate = Color.WHITE
			var tween = create_tween()
			tween.tween_property(_control, "modulate", Color.TRANSPARENT, 0.25)
			await tween.finished
			visible = false
			ScreenFade.set_circle(1.0, 0.5)
			await ScreenFade.done
			_tweening = false
			DialogueController.visible = true
			get_tree().paused = false
