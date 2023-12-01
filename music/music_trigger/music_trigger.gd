extends Area2D

@export var _transition_duration := 1.0
@export var _organ_volume := 0
@export var _drum1_volume := 0
@export var _drum2_volume := 0
@export var _drum3_volume := 0
@export var _flute_volume := 0
@export var _harp_volume := 0
@export var _guitar_volume := 0

@export var _stop_synth := false

func _ready():
	body_entered.connect(_on_body_entered)
	

func _on_body_entered(_body) -> void:
	MusicPlayer.set_volumes(
			_transition_duration,
			_organ_volume,
			_drum1_volume,
			_drum2_volume,
			_drum3_volume,
			_flute_volume,
			_harp_volume,
			_guitar_volume
	)
	if _stop_synth:
		MusicPlayer.stop_synth()
	queue_free()
