extends AnimatedSprite2D
class_name Switch

func _ready() -> void:
	($GrappleArea as Area2D).body_entered.connect(_on_grappled)

func _on_grappled(_body: Node2D) -> void:
	print("Triggered!")
