extends CanvasLayer

const MAX_CIRCLE_SIZE = 1.145

signal done

var _circle_size := MAX_CIRCLE_SIZE
var _player: Node2D
var _tween: Tween

@export var _shader: ShaderMaterial

func _ready():
	_player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	_set_center()
	_set_circle_size()


func _set_center() -> void:
	var screen_pos: Vector2
	if _player == null or not is_instance_valid(_player):
		screen_pos = Vector2(0.5, 0.5)
	else:
		screen_pos = _player.get_global_transform_with_canvas().origin
		screen_pos = Vector2(screen_pos.x / 180, screen_pos.y / 320)
	_shader.set_shader_parameter("center", screen_pos)
	

func _set_circle_size() -> void:
	_shader.set_shader_parameter("circle_size", _circle_size)
	

func set_circle(circle_pixels: float, duration := 0.0) -> void:
	if _tween != null and not _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_EXPO)
	_tween.tween_property(self, "_circle_size", circle_pixels, duration)
	_tween.tween_callback(func(): done.emit())
