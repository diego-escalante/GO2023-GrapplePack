extends Node

var slow_mode := false
var invinsible := false
var long_grapple := false

var elapsed_time := 0.0
var deaths := 0

var _spawn_position: Vector2 :
	set(val):
		_spawn_position = val
		_is_checkpoint_set = true
var _is_checkpoint_set := false

func _process(delta: float) -> void:
	if not get_tree().paused:
		elapsed_time += delta

func is_checkpoint_set() -> bool:
	return _is_checkpoint_set


func set_checkpoint(checkpoint: Checkpoint) -> void:
	_spawn_position = checkpoint.global_position + Vector2.DOWN * 6.5


func move_player_to_checkpoint() -> void:
	if _is_checkpoint_set:
		deaths += 1
		var player := get_tree().get_first_node_in_group("player") as Player
		player.global_position = _spawn_position
		player.freeze_position = false
		get_tree().get_first_node_in_group("grapple_pack").queue_free()
