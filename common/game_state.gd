extends Node

var _spawn_position: Vector2 :
	set(val):
		_spawn_position = val
		_is_checkpoint_set = true
var _is_checkpoint_set := false

func is_checkpoint_set() -> bool:
	return _is_checkpoint_set


func set_checkpoint(checkpoint: Checkpoint) -> void:
	_spawn_position = checkpoint.global_position + Vector2.DOWN * 6.5


func move_player_to_checkpoint() -> void:
	if _is_checkpoint_set:
		var player := get_tree().get_first_node_in_group("player") as Player
		player.global_position = _spawn_position
		player.freeze_position = false
		get_tree().get_first_node_in_group("grapple_pack").queue_free()
