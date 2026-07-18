class_name MapRoomMarker
extends Sprite2D

@export var area: String
@export var modify_flag: String
@export var modify_region: Rect2

func _ready() -> void:
	if modify_flag != "" and Global.flags.has(modify_flag):
		self.region_rect = modify_region
