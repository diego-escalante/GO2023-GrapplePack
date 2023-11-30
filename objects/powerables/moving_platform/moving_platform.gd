extends Powerable
class_name MovingPlatform

@export var speed := 1.0
@export var _draw_path := true

@onready var _path := $Path2D as Path2D
@onready var _path_follow := $PathFollow2D as PathFollow2D
@onready var _line := $Line2D as Line2D

func _ready() -> void:
	super()
	if _path == null:
		push_error("No Path2D child node attached to %s!" % name)
	_path_follow.reparent(_path)
	if _draw_path:
		_draw_line()
	_path_follow.progress = 0

func _physics_process(delta: float):
	if _is_powered:
		_path_follow.progress += speed * GameConsts.PIXELS_PER_UNIT * delta
	
func _draw_line() -> void:
	for i in _path.curve.point_count:
		_line.add_point(_path.curve.get_point_position(i))
