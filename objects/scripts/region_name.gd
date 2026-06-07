extends Node2D

@export var region_name: String
@export var amount_visible := 0.:
	set(value):
		var width: float = $PanelContainer.size.x
		position.x = (value - 1) * width
@export var require_explored := true

func _ready() -> void:
	if require_explored and !Global.flags.has(Global.scene_flag_name("explored")):
		queue_free()
	$PanelContainer/RegionName.text = region_name
