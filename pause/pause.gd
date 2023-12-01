extends CanvasLayer

@export var sample_sounds: Array[AudioStream] = []

var _is_paused := false
var _tweening := false
var master_bus := AudioServer.get_bus_index("Master")
var music_bus := AudioServer.get_bus_index("Music")
var sound_bus := AudioServer.get_bus_index("Sounds")
var voices_bus := AudioServer.get_bus_index("Voices")


var _player : Player
var _player_hitbox : Area2D

@onready var _control := $Control


func _ready() -> void:
	visible = false
	_player = get_tree().get_first_node_in_group("player") as Player
	_player_hitbox = _player.get_node("Hitbox") as Area2D
	($Control/VBoxContainer/HBoxContainer4/VBoxContainer2/long_grapple_check as CheckBox).button_pressed = GameState.long_grapple
	($Control/VBoxContainer/HBoxContainer4/VBoxContainer2/slow_mode_check as CheckBox).button_pressed = GameState.slow_mode
	($Control/VBoxContainer/HBoxContainer4/VBoxContainer2/invinsibility_check as CheckBox).button_pressed = GameState.invinsible
	($Control/VBoxContainer/HBoxContainer3/VBoxContainer2/master_slider as HSlider).value = AudioServer.get_bus_volume_db(master_bus)
	($Control/VBoxContainer/HBoxContainer3/VBoxContainer2/music_slider as HSlider).value = AudioServer.get_bus_volume_db(music_bus)
	($Control/VBoxContainer/HBoxContainer3/VBoxContainer2/sounds_slider as HSlider).value = AudioServer.get_bus_volume_db(sound_bus)
	($Control/VBoxContainer/HBoxContainer3/VBoxContainer2/voices_slider as HSlider).value = AudioServer.get_bus_volume_db(voices_bus)

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


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, value)


func _on_sounds_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sound_bus, value)


func _on_voices_slider_value_changed(value):
	AudioServer.set_bus_volume_db(voices_bus, value)


func _on_long_grapple_check_toggled(toggled_on):
	_player._grapple.grapple_length = 10 if toggled_on else 5
	GameState.long_grapple = toggled_on


func _on_invinsibility_check_toggled(toggled_on):
	_player_hitbox.set_collision_mask_value(5, not toggled_on)
	GameState.invinsible = toggled_on


func _on_slow_mode_check_toggled(toggled_on):
	Engine.time_scale = 0.5 if toggled_on else 1.0
	GameState.slow_mode = toggled_on
