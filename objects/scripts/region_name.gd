extends Node2D

@export var region_name: String
@export var amount_visible := 0.:
	set(value):
		var width: float = $PanelContainer.size.x
		position.x = (value - 1) * width

func _ready() -> void:
	$PanelContainer/RegionName.text = region_name
