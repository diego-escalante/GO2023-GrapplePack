extends CharacterBody2D

var is_falling := false

#36.75

func _ready() -> void:
	pass
#	velocity = 

func _physics_process(_delta: float) -> void:
	if not is_falling:
		return
	
	
