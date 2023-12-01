extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(audio: AudioStream, vol_db := 0.0, pitch := 0.0) -> void:
	var player := AudioStreamPlayer.new()
	player.finished.connect(func(): player.queue_free())
	add_child(player)
	player.bus = "PreSounds"
	player.stream = audio
	player.volume_db = vol_db + 3.0
	if pitch != 0:
		player.pitch_scale = pitch
	player.play()
