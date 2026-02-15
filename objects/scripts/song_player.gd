extends Node

@export var song_stream: AudioStream

func _ready() -> void:
	Global.play_music(song_stream)
