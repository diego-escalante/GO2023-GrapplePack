extends CanvasLayer

@export var _next_scene : PackedScene

var _tween: Tween
@onready var _container := $VBoxContainer
@onready var _no_button := $VBoxContainer/HBoxContainer/NoButton as Button
@onready var _yes_button := $VBoxContainer/HBoxContainer/YesButton as Button

func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_tree().change_scene_to_packed(_next_scene)
		return
	_no_button.pressed.connect(_exit.bind(false)) 
	_yes_button.pressed.connect(_exit.bind(true))
	_container.modulate = Color(1, 1, 1, 0)
	_tween = create_tween()
	_tween.tween_property(_container, "modulate", Color(1, 1, 1, 1), 1).set_delay(0.5)


func _exit(to_fullscreen: bool) -> void:
	_no_button.pressed.disconnect(_exit)
	_yes_button.pressed.disconnect(_exit)
	if to_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_container, "modulate", Color(1, 1, 1, 0), 1)
	_tween.tween_callback(func(): get_tree().change_scene_to_packed(_next_scene)).set_delay(1)
