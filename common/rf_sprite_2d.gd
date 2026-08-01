@tool
class_name RFSprite2D
extends Sprite2D

@export var region_frames: RegionFrames:
	set(value):
		region_frames = value
		update_configuration_warnings()
@export var current_frame := 0:
	set(value):
		if region_frames == null or region_frames.frames.is_empty():
			current_frame = -1
			region_rect = Rect2i(0, 0, texture.get_width(), texture.get_height())
		else:
			current_frame = clampi(value, 0, region_frames.frames.size() - 1)
			region_rect = region_frames.frames.get(current_frame)

func _get_configuration_warnings() -> PackedStringArray:
	if region_frames == null:
		return ["region_frames is not defined. The sprite will not have any frames."]
	return []
