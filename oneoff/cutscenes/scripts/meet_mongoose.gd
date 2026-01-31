extends Node2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")

const ECHO_WALK_OFFSET := 24.
const LEFT_OFFSET := ECHO_WALK_OFFSET
const RIGHT_OFFSET := Util.ROOM_SIZE - ECHO_WALK_OFFSET
const ECHO_Y_OFFSET := Util.ROOM_SIZE - 24. - 9.

var chunk: Vector2i

signal cutscene_over()

func _ready() -> void:
	chunk = Util.chunk_of(global_position)
	Global.chunk_loaded.connect(on_chunk_load)

func on_chunk_load(x: int, y: int) -> void:
	if Vector2i(x, y) == chunk:
		get_tree().paused = true
		$CutsceneBars.start()
		var enter_right := Global.echo.global_position.x > global_position.x + Util.ROOM_SIZE / 2
		
		$Mongoose.show()
		$Mongoose.position.x = LEFT_OFFSET if enter_right else RIGHT_OFFSET
		$Mongoose.flip_h = !enter_right
		$AnimationPlayer.play("mongoose_idle")
		
		var echo_walker: Node2D = EchoCutsceneWalker.instantiate()
		echo_walker.x_destination = RIGHT_OFFSET if enter_right else LEFT_OFFSET
		echo_walker.face_right_on_deletion = !enter_right
		add_child(echo_walker)
		echo_walker.position.y = ECHO_Y_OFFSET
		echo_walker.dest_reached.connect($NoticeDelay.start)

func end_cutscene() -> void:
	$Mongoose.hide()
	$CutsceneBars.end()
	get_tree().paused = false
	cutscene_over.emit()
