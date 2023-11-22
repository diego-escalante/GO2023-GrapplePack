extends Node

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


func respawn() -> void:
	get_tree().reload_current_scene()
