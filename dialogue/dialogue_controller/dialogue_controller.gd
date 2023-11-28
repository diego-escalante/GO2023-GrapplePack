extends CanvasLayer
class_name DialogueController

const HANDLER_COLOR := Color(0.471, 0.514, 0.455)
const FOX_COLOR := Color(0.667, 0.392, 0.302)
const NONE_COLOR := Color(0.961, 0.914, 0.749)

var _queue : Array[Dialogue]
var _tween : Tween

@onready var _label := $MarginContainer/Label as Label

func _process_queue() -> void:
	if _queue.is_empty() or _label.modulate != Color.TRANSPARENT:
		return
	_display_dialogue(_queue.pop_front())

func _display_dialogue(dialogue: Dialogue) -> void:
	_label.modulate = Color.TRANSPARENT
	var color: Color
	match dialogue.source:
		"handler":
			color = HANDLER_COLOR
		"fox":
			color = FOX_COLOR
		"none":
			color = NONE_COLOR
	_label.add_theme_color_override("font_color", color)
	_label.text = dialogue.text
	_tween = create_tween()
	_tween.tween_property(_label, "modulate", Color.WHITE, 0.2)
	_tween.tween_property(_label, "modulate", Color.TRANSPARENT, 0.2).set_delay(dialogue.duration)
	await _tween.finished
	_process_queue()
	

func _force_clear() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_label, "modulate", Color.TRANSPARENT, 0.2)
		await _tween.finished
		_process_queue()


func queue_up(dialogues: Array[Dialogue], high_priority := false) -> void:
	if high_priority:
		dialogues.append_array(_queue)
		_queue = dialogues
		_force_clear()
	else:
		_queue.append_array(dialogues)
	_process_queue()