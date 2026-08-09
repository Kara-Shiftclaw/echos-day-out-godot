@tool
class_name RFSprite2Dv2
extends Sprite2D

@export var current_frame := 0:
	set(value):
		current_frame = clampi(value, 0, frame_count)
		region_rect = frame_regions.get(current_frame)
		offset = frame_offsets.get(current_frame)
@export_range(1, 100) var frame_count := 1:
	set(value):
		if value > frame_regions.size():
			frame_regions.resize(value)
			frame_offsets.resize(value)
		frame_count = value
		notify_property_list_changed()

var frame_regions: Array[Rect2] = [Rect2()]
var frame_offsets: Array[Vector2] = [Vector2.ZERO]


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for i in range(0, frame_count):
		properties.append({
			name = "Frame %d" % i,
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP
		})
		properties.append({
			name = "frame_%d_region" % i,
			type = TYPE_RECT2,
			usage = PROPERTY_USAGE_DEFAULT
		})
		properties.append({
			name = "frame_%d_offset" % i,
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT
		})
	return properties

func _get(property: StringName) -> Variant:
	var maybe_frame_region = maybe_get_frame_region(property)
	if maybe_frame_region != null:
		return frame_regions[maybe_frame_region]
	var maybe_frame_offset = maybe_get_frame_offset(property)
	if maybe_frame_offset != null:
		return frame_offsets[maybe_frame_offset]
	return null

func _set(property: StringName, value: Variant) -> bool:
	var maybe_frame_region = maybe_get_frame_region(property)
	if maybe_frame_region != null and value is Rect2:
		frame_regions[maybe_frame_region] = value as Rect2
		return true
	var maybe_frame_offset = maybe_get_frame_offset(property)
	if maybe_frame_offset != null and value is Vector2:
		frame_offsets[maybe_frame_offset] = value as Vector2
		return true
	return false


func maybe_get_frame_region(property: StringName):
	var split_property := property.split("_")
	if split_property.size() == 3 and split_property[0] == "frame" and split_property[2] == "region":
		return int(split_property[1])
	return null

func maybe_get_frame_offset(property: StringName):
	var split_property := property.split("_")
	if split_property.size() == 3 and split_property[0] == "frame" and split_property[2] == "offset":
		return int(split_property[1])
	return null
