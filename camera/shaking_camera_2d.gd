extends Camera2D
class_name ShakingCamera2D

const MAX_TRAUMA := 2.0
const MIN_TRAUMA := 0.0

@export var shake_enabled := true
@export var _trauma_decay_per_second := 1.0
@export var _max_shake_offset := Vector2.ONE * GameConsts.PIXELS_PER_UNIT
@export var _max_shake_angle := 5.0
@export var _noise := FastNoiseLite.new()

var _current_trauma: float
var _shake_strength: float
var _time_elapsed_ms: float

func _process(delta: float) -> void:
	_time_elapsed_ms += delta * 1000
	
	if not shake_enabled or is_equal_approx(_current_trauma, MIN_TRAUMA):
		return
		
	_current_trauma = max(MIN_TRAUMA, _current_trauma - _trauma_decay_per_second * delta)
	_shake_strength = pow(_current_trauma, 2)
	
	rotation_degrees = _max_shake_angle * _shake_strength * _noise.get_noise_3d(_time_elapsed_ms, 0, 0)
	offset = Vector2(
			_max_shake_offset.x * _shake_strength * _noise.get_noise_3d(0, _time_elapsed_ms, 0),
			_max_shake_offset.y * _shake_strength * _noise.get_noise_3d(0, 0, _time_elapsed_ms)
	)

func add_trauma(amount: float) -> void:
	if not shake_enabled:
		return
	_current_trauma = min(_current_trauma + amount, MAX_TRAUMA)
