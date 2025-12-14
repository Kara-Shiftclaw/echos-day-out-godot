class_name FollowCamera
extends Camera2D

const BASE_OFFSET := Vector2(64., 64.)

var chunk := Vector2i(9999, 9999)

@export var following: Node2D
@export var stage_transition_parent: Node

var stage_transition_spaces: Dictionary[Vector2i, StageTransition]

func _ready() -> void:
	Global.camera = self
	if stage_transition_parent != null:
		if stage_transition_parent.is_node_ready():
			calculate_stage_transitions()
		else:
			print("Awaiting readiness to calculate stage transitions...")
			stage_transition_parent.ready.connect(calculate_stage_transitions)

func _process(_delta: float) -> void:
	recalculate_chunk()

func recalculate_chunk() -> void:
	var new_chunk := (following.global_position / Util.ROOM_SIZE).floor() as Vector2i
	if new_chunk != chunk:
		var stage_transition: StageTransition = stage_transition_spaces.get(new_chunk)
		if stage_transition != null:
			var transition_other_side := Vector2(new_chunk - chunk) * (Util.ROOM_SIZE + 1.)
			var new_world_offset := following.global_position + transition_other_side - stage_transition.global_position
			var other_transition_path = stage_transition.get_other_transition_path()
			
			var transition := Echo.DeathScreen.instantiate()
			add_child(transition)
			transition.halfway.connect(func():
				Global.load_new_stage(stage_transition.other_stage, new_world_offset, other_transition_path)
			)
		else:
			chunk = new_chunk
			Global.load_chunk(chunk.x, chunk.y)
	global_position = chunk * Util.ROOM_SIZE

func calculate_stage_transitions() -> void:
	for stage_transition: StageTransition in stage_transition_parent.get_children():
		for room in stage_transition.get_all_rooms():
			stage_transition_spaces[Vector2i(room)] = stage_transition
	print(stage_transition_spaces)
