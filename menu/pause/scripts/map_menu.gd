extends Panel

const CENTER := Vector2(51., 46.)

func _ready() -> void:
	call_deferred("grab_focus")
	populate_dest_maps()

func populate_dest_maps() -> void:
	var cur_stage := get_tree().current_scene.name
	var cur_stage_offset := Vector2.ZERO
	var map_parent = $Outline/Background/MapParent
	
	for stage in Global.explored_spaces:
		var source_map_layer: TileMapLayer = $SourceMap.get_node(stage as String)
		var dest_map_layer := source_map_layer.duplicate()
		$Outline/Background/MapParent.add_child(dest_map_layer)
		var dest_map_back: TileMapLayer = dest_map_layer.get_child(0)
		
		var stage_explored_spaces: Dictionary = Global.explored_spaces[stage]
		for cell in dest_map_back.get_used_cells():
			if !stage_explored_spaces.has(explored_space_coord(cell)):
				dest_map_layer.erase_cell(cell)
				dest_map_back.erase_cell(cell)
		
		if stage == cur_stage:
			cur_stage_offset = dest_map_layer.position
	
	var chunk_offset := 8 * Global.camera.chunk + Vector2i(4, 4)
	
	var echo_marker: Node2D = map_parent.get_node("EchoMarker")
	echo_marker.position = cur_stage_offset + Vector2(chunk_offset)
	map_parent.position = CENTER - echo_marker.position

func explored_space_coord(cell_coord: Vector2i) -> String:
	var space_x := floori(cell_coord.x / 2.)
	var space_y := floori(cell_coord.y / 2.)
	
	return Global.explored_space_str(space_x, space_y)
