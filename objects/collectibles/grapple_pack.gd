extends Sprite2D
class_name GrapplePack

@export var _packed_title: PackedScene
@export var _dialogues: Array[Dialogue]

@onready var _area := $Area2D as Area2D
@onready var _animation_player := $AnimationPlayer as AnimationPlayer

func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	

func _process(_delta: float) -> void:
	_animation_player.speed_scale = 1.0 / Engine.time_scale

func _on_body_entered(_body: Node2D) -> void:
	_area.body_entered.disconnect(_on_body_entered)

	ScreenFade.set_circle(0.15, 0.75)
	TimeController.scale_time(0.01, 0.1)
	await ScreenFade.done
	var title = _packed_title.instantiate()
	owner.add_child(title)
	
	_animation_player.play("despawn")
	await _animation_player.animation_finished
	(get_tree().get_first_node_in_group("player") as Player).set_input_enabled(true, true)

	ScreenFade.set_circle(1, 0.75)
	TimeController.scale_time(1, 0.75)
	
	await get_tree().create_timer(2.5).timeout
	
	(get_tree().get_first_node_in_group("dialogue_controller") as DialogueController).queue_up(_dialogues)
	
	queue_free()
