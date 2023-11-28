extends CanvasLayer

const MAX_CIRCLE_SIZE = 1.145

signal done

var _circle_size := MAX_CIRCLE_SIZE
var _player: Node2D
var _tween: Tween

@onready var _color_rect := $ColorRect as ColorRect
var _shader: ShaderMaterial

func _ready() -> void:
	_shader = _color_rect.material

func _process(_delta: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.set_speed_scale(1.0/Engine.time_scale)
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
	

func set_circle(value: float, duration := 0.0, color := Color(0.216, 0.165, 0.224)) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	var circle_size := remap(value, 0, 1, 0, MAX_CIRCLE_SIZE)
	_color_rect.color = color
	if duration <= 0:
		_circle_size = circle_size
		_set_circle_size()
		done.emit()
		return

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_EXPO)
	_tween.tween_property(self, "_circle_size", circle_size, duration)
	_tween.tween_callback(func():  done.emit())
