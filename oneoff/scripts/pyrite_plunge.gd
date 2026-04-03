extends Node2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")

const FALL_CUTSCENE_CHUNK := Vector2i(0, 2)
const FALL_DESTINATION := 64.

func _ready() -> void:
	if Global.flags.has("green_plant_open") or $Camera2D.chunk.y == 9:
		disable_stage_transitions()
	else:
		Global.chunk_loaded.connect(no_green_plant_chunk_loaded)

func no_green_plant_chunk_loaded(cx: int, cy: int) -> void:
	if cy == 9: # Lowest level
		disable_stage_transitions()
	elif Vector2i(cx, cy) == FALL_CUTSCENE_CHUNK:
		fall_cutscene()

func disable_stage_transitions() -> void:
	$StageTransitions/ToLower.disable()
	$StageTransitions/ToUpper.disable()

func fall_cutscene() -> void:
	$Objects/Row1/CutsceneBars.show()
	$Objects/Row1/CutsceneBars.start()
	var echo_walker: Node2D = EchoCutsceneWalker.instantiate()
	echo_walker.x_destination = FALL_DESTINATION
	echo_walker.face_right_on_deletion = Global.echo.global_position.x < FALL_DESTINATION
	add_child(echo_walker)
	
	echo_walker.dest_reached.connect(func():
		$Objects/Row1/AnimationPlayer.play("drop_player")
		$Objects/Row1/CutsceneBars.end()
	)
