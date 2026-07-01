extends Button

class Metadata:
	extends RefCounted
	
	var flag: String
	var title: String
	var description_translation: String
	var frame: int
	
	func _init(flag_: String, title_: String, desc_: String, frame_: int) -> void:
		flag = flag_
		title = title_
		description_translation = desc_
		frame = frame_

var metadata: Metadata

func _ready() -> void:
	$Sprite2D.frame = metadata.frame
