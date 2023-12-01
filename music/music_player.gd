extends Node

signal done

var _tween: Tween

@onready var _organ := $Organ as AudioStreamPlayer
@onready var _drum1 := $Drum1 as AudioStreamPlayer
@onready var _drum2 := $Drum2 as AudioStreamPlayer
@onready var _drum3 := $Drum3 as AudioStreamPlayer
@onready var _flute := $Flute as AudioStreamPlayer
@onready var _harp := $Harp as AudioStreamPlayer
@onready var _guitar := $Guitar as AudioStreamPlayer
@onready var _synth := $Synth as AudioStreamPlayer

func set_volumes(
		transition_duration: float, 
		organ_vol: float, 
		drum1_vol: float, 
		drum2_vol: float, 
		drum3_vol: float, 
		flute_vol: float, 
		harp_vol: float, 
		guitar_vol: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_organ, "volume_db", _remap(organ_vol), transition_duration)
	_tween.tween_property(_drum1, "volume_db", _remap(drum1_vol), transition_duration)
	_tween.tween_property(_drum2, "volume_db", _remap(drum2_vol), transition_duration)
	_tween.tween_property(_drum3, "volume_db", _remap(drum3_vol), transition_duration)
	_tween.tween_property(_flute, "volume_db", _remap(flute_vol), transition_duration)
	_tween.tween_property(_harp, "volume_db", _remap(harp_vol), transition_duration)
	_tween.tween_property(_guitar, "volume_db", _remap(guitar_vol), transition_duration)
	_tween.tween_callback(func(): done.emit())
	

func start_playing_synth() -> void:
	_synth.play()
	_synth.finished.connect(_on_synth_finish)
	
	
func stop_synth() -> void:
	var tween := create_tween()
	tween.tween_property(_synth, "volume_db", _remap(0), 10)
	

func _on_synth_finish() -> void:
	get_tree().create_timer(randi_range(60, 120)).timeout.connect(func(): _synth.play())
	

func _remap(vol: float) -> float:
	return remap(vol, 0.0, 1.0, -80.0, 0.0)
