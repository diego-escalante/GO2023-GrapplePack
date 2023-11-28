extends Resource
class_name Dialogue

@export var sound: AudioStream
@export_multiline var text: String
@export var duration: float
@export_enum("handler", "fox", "none") var source: String = "handler"
