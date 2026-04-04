extends Node2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")
const SmallPyriteChunk := preload("res://oneoff/small_pyrite_chunk.tscn")

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

func spawn_pyrite(src: Node2D) -> void:
	var damage := src.get_node_or_null("Damage")
	if damage != null and damage.active:
		$Objects/BigLump/AnimationPlayer.play("hit")
		for i in range(0, damage.damage / 2):
			var angle := -randf() * PI / 2.
			var force := randf_range(9000., 18000.)
			var vector := Vector2.from_angle(angle)
			var chunk: RigidBody2D = SmallPyriteChunk.instantiate()
			$Objects/BigLump.call_deferred("add_child", chunk)
			chunk.position = vector * 4.25 * 8.
			chunk.apply_force(vector * force)
			chunk.collected.connect(pyrite_collected)

func pyrite_collected(full: bool) -> void:
	$Camera2D/PyriteCount/Panel/Label.text = "%03d" % Global.flags.get("pyrite", 0)
	$Camera2D/PyriteCount/AnimationPlayer.play("slide_in")
	if !full:
		$Objects/BigLump/Collect.play()
