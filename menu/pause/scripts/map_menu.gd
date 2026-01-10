extends Panel

const CENTER := Vector2(51., 46.)
const SCROLL_SPEED := 20. * 8.

const HINT_FIREBALL := "hint_fireball"
const HINT_DOUBLE_JUMP := "hint_double_jump"
const HINT_SPRINT := "hint_sprint"
const HINT_CRUSH := "hint_crush"

func _ready() -> void:
	call_deferred("grab_focus")
	populate_dest_maps()
	if Global.weight == Global.Weight.Blob:
		$Outline/Background/MapParent/EchoMarker.frame = 1

func _process(delta: float) -> void:
	if has_focus():
		var map_scroll := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		$Outline/Background/MapParent.position -= map_scroll * SCROLL_SPEED * delta

func _input(event: InputEvent) -> void:
	if has_focus():
		if (event.is_echo() or event.is_pressed()) and \
				(event.is_action("ui_up") or event.is_action("ui_left") or \
				event.is_action("ui_right") or event.is_action("ui_down")):
			get_viewport().set_input_as_handled()
		if event.is_action_pressed("ui_cancel"):
			print("Grabbing top focus")
			find_valid_focus_neighbor(SIDE_TOP).call_deferred("grab_focus")

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
	
	map_parent.get_node("FireballHint").visible = Global.flags.has(HINT_FIREBALL)
	map_parent.get_node("DoubleJumpHint").visible = Global.flags.has(HINT_DOUBLE_JUMP)
	map_parent.get_node("SprintHint").visible = Global.flags.has(HINT_SPRINT)
	map_parent.get_node("CrushHint").visible = Global.flags.has(HINT_CRUSH)

func explored_space_coord(cell_coord: Vector2i) -> String:
	var space_x := floori(cell_coord.x / 2.)
	var space_y := floori(cell_coord.y / 2.)
	
	return Global.explored_space_str(space_x, space_y)
