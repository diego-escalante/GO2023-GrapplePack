extends Node
class_name GameController

@onready var _player := $Player as Player
@onready var _camera := $Camera as ShakingCamera2D

func _ready() -> void:
	_player.just_grounded.connect(_on_intro_player_just_grounded)
	ScreenFade.set_circle(0, 0, Color.BLACK)
	await get_tree().create_timer(0.5).timeout
	ScreenFade.set_circle(1, 2, Color.BLACK)


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event.is_pressed():
		
		# Debug commands
		if OS.has_feature("debug"):
			match key_event.keycode:
				KEY_ESCAPE:
					if OS.get_name() != "Web":
						get_tree().quit()
				KEY_R:
					get_tree().reload_current_scene()
		
		# Prod commands
		match key_event.keycode:
			KEY_F11:
				if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_intro_player_just_grounded() -> void:
	_player.just_grounded.disconnect(_on_intro_player_just_grounded)
	_player.freeze_position = true
	_player._sprite.play("crouch")
	_camera.add_trauma(0.85)
	await get_tree().create_timer(1).timeout
	_player.freeze_position = false
	_player.set_input_enabled(true, false)


func respawn() -> void:
	get_tree().reload_current_scene()
