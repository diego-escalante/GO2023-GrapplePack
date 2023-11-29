extends Node2D
class_name LocationTrigger

@export var _clear_dialogue := false
@export var _dialogues : Array[Dialogue]
@export var _high_priority := false

var _area: Area2D
var _timer: Timer

func _ready() -> void:
	if _dialogues == null and not _clear_dialogue:
		push_error("No dialogue attached to %s!" % name)
		queue_free()
	
	for child in get_children():
		if child is Area2D:
			_area = child as Area2D
		elif child is Timer:
			_timer = child as Timer
			_timer.timeout.connect(_on_timer_timeout)

	if _area == null:
		push_error("No Area2D child attached to %s!" % name)
		queue_free()
		
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)


func _on_body_entered(_body: Node2D) -> void:
	if _timer == null:
		DialogueController.queue_up(_dialogues, _high_priority)
		queue_free()
		return
	_timer.start()


func _on_body_exited(_body: Node2D) -> void:
	if _timer != null:
		_timer.stop()


func _on_timer_timeout() -> void:
	DialogueController.queue_up(_dialogues, _high_priority)
	queue_free()
