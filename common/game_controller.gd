extends Node
class_name GameController

@export var _dialogues: Array[Dialogue] = []
@export var _respawn_dialogues : Array[Dialogue] = []
@export var _big_thud_sound: AudioStream

@export var _fast_sound: AudioStream
@export var _slow_sound: AudioStream

@onready var _player := $Player as Player
@onready var _camera := $Camera as ShakingCamera2D
@onready var _player_shader := (_player.get_node("AnimatedSprite2D") as AnimatedSprite2D).material as ShaderMaterial


func _ready() -> void:
	_set_dissolve(0)
	_set_colorize(0)
	if GameState.is_checkpoint_set():
		_player.set_input_enabled(false, true)
		ScreenFade.set_circle(0, 0)
		GameState.move_player_to_checkpoint()
		_camera.position_smoothing_enabled = false
		get_tree().create_timer(0.1).timeout.connect(func(): _camera.position_smoothing_enabled = true)
		ScreenFade.set_circle(1, 1)
		_set_colorize(1)
		_set_dissolve(1)
		var tween = create_tween()
		tween.set_parallel(false)
		SoundController.play(_fast_sound, -12, 0.4)
		tween.tween_method(_set_dissolve, 1.0, 0.0, 0.4).set_delay(0.3)
		tween.tween_method(_set_colorize, 1.0, 0.0, 0.2)
		await get_tree().create_timer(0.5).timeout
		_player.set_input_enabled(true, true)
		DialogueController.queue_up(_respawn_dialogues)
		return
	
	_player.just_grounded.connect(_on_intro_player_just_grounded)
	ScreenFade.set_circle(0, 0, Color.BLACK)
	await get_tree().create_timer(0.5).timeout
	ScreenFade.set_circle(1, 2, Color.BLACK)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED


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
	SoundController.play(_big_thud_sound)
	_player.freeze_position = true
	_player._sprite.play("crouch")
	_camera.add_trauma(0.85)
	await get_tree().create_timer(1).timeout
	DialogueController.queue_up(_dialogues)
	await get_tree().create_timer(11).timeout
	_player.freeze_position = false
	_player.set_input_enabled(true, false)
	MusicPlayer.set_volumes(1, 1, 0, 0, 0, 0, 0, 0)


func respawn() -> void:
	_player.freeze_position = true
	ScreenFade.set_circle(0.15, 0.75)
	TimeController.scale_time(0.01, 0.1)
	await ScreenFade.done
	SoundController.play(_slow_sound, -12, 0.4)
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_method(_set_colorize, 0.0, 1.0, 0.0025)
	tween.tween_method(_set_dissolve, 0.0, 1.0, 0.005)
	await tween.finished

	ScreenFade.set_circle(0, 0.5)
	TimeController.scale_time(1.0 if not GameState.slow_mode else 0.5, 0.5)
	await TimeController.time_scaling_done

	get_tree().reload_current_scene()
	

func _set_dissolve(value: float) -> void:
	_player_shader.set_shader_parameter("sensitivity", value)


func _set_colorize(value: float) -> void:
	_player_shader.set_shader_parameter("percentage", value)


func _on_end_area_body_entered(_body):
	_player.freeze_position = true
	_player.set_input_enabled(false, false)
	ScreenFade.set_circle(0.0, 5.0)
	await ScreenFade.done
	var tween := create_tween()
	$End/Control.modulate = Color.TRANSPARENT
	($End/Control/VBoxContainer/TimeLabel as Label).text = "Duration: %dm %ds" % [floor(GameState.elapsed_time / 60), int(GameState.elapsed_time) % 60]
	($End/Control/VBoxContainer/DeathsLabel as Label).text = "Super Duper Puter Saves: %d" % GameState.deaths
	$End.visible = true
	tween.tween_property($End/Control, "modulate", Color.WHITE, 2.0)
