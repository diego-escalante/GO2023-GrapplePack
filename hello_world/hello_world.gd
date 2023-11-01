extends Node

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if (event as InputEventKey).pressed:
			RenderingServer.set_default_clear_color(Color(randf(), randf(), randf()))
