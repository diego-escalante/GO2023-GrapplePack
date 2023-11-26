extends Node

@onready var fullscreen_prompt := $FullscreenPrompt as FullscreenPrompt

func _ready() -> void:
	fullscreen_prompt.done.connect(_prompt_done)
	ScreenFade.set_circle(0, 0, Color("222222"))


func _prompt_done() -> void:
	ScreenFade.set_circle(1, 2)
