class_name TextEngine
extends Node

class Option:
	extends RefCounted
	
	var display_text: String
	var description: String
	
	func _init(display_text_: String, description_: String = "") -> void:
		display_text = display_text_
		description = description_
