extends CharacterBody2D
class_name Player

@export var input_enabled := true

func _physics_process(_delta: float) -> void:
	move_and_slide()
