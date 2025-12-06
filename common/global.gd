extends Node

signal save()
signal chunk_loaded(cx: int, cy: int)

var echo: Echo
var camera: FollowCamera
var health_bar: HealthBar
var save_id := 1

var flags := {}

func save_data(save_point: Node) -> void:
	var save_dict := {
		"stage": save_point.get_tree().current_scene.scene_file_path,
		"save_point": save_point.get_path(),
		"flags": flags,
	}
	var save_file := FileAccess.open(save_path(save_id), FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict))
	save.emit()

func load_data(load_id: int) -> void:
	save_id = load_id
	var load_file := FileAccess.open(save_path(load_id), FileAccess.READ)
	var load_json: Dictionary = JSON.parse_string(load_file.get_line())
	flags = load_json["flags"]
	
	get_tree().scene_changed.connect(func():
		var save_point_path: String = load_json["save_point"]
		var save_point: Node2D = get_tree().current_scene.get_node_or_null(save_point_path)
		if save_point == null:
			push_error("Save point {0} not found".format([save_point_path]))
		
		echo.global_position = save_point.global_position
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar()
	, ConnectFlags.CONNECT_ONE_SHOT)
	get_tree().change_scene_to_file(load_json["stage"])

func load_new_stage(stage: String,
		new_world_offset: Vector2,
		other_transition_path: String) -> void:
	var echo_health = echo.health
	get_tree().change_scene_to_file(stage)
	get_tree().scene_changed.connect(func():
		print(get_tree().current_scene.is_node_ready())
		var other_transition := get_tree().current_scene.get_node(other_transition_path)
		echo.global_position = other_transition.global_position + new_world_offset
		echo.health = echo_health
		camera.recalculate_chunk()
		health_bar.recalculate_health_bar()
	, ConnectFlags.CONNECT_ONE_SHOT)

func set_node_flag(node: Node, flag: String, value: int = 1) -> void:
	var flag_name := node_flag_name(node, flag)
	flags[flag_name] = value

func has_node_flag(node: Node, flag: String) -> bool:
	var flag_name := node_flag_name(node, flag)
	return flags.has(flag_name)

func load_chunk(cx: int, cy: int) -> void:
	chunk_loaded.emit(cx, cy)

func node_flag_name(node:Node, flag: String) -> String:
	return "{0}|{1}|{2}".format([get_tree().current_scene.scene_file_path, node.get_path(), flag])

static func save_path(path_save_id: int) -> String:
	return "user://save_{0}.json".format([path_save_id])
