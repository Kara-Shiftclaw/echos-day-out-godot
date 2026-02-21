extends Node2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")
const MongooseBoss := preload("res://oneoff/bosses/mongoose.tscn")

const ECHO_WALK_OFFSET := 24.
const LEFT_OFFSET := ECHO_WALK_OFFSET
const RIGHT_OFFSET := Util.ROOM_SIZE - ECHO_WALK_OFFSET
const ECHO_Y_OFFSET := Util.ROOM_SIZE - 24. - 9.
const UPGRADE_OFFSET := Vector2(Util.ROOM_SIZE / 2., Util.ROOM_SIZE - 6. * 8.)
const COMPLETED_FLAG := "mongoose_boss_completed"
const MONOLOGUE_FLAG := "mongoose_boss_monologue"

var chunk: Vector2i
@export var boss_theme: AudioStream

signal cutscene_over()
signal failed()
signal completed()

func _ready() -> void:
	if Global.flags.has(COMPLETED_FLAG):
		queue_free()
	chunk = Util.chunk_of(global_position)
	Global.chunk_loaded.connect(on_chunk_load)

func on_chunk_load(x: int, y: int) -> void:
	if Global.flags.has(COMPLETED_FLAG):
		queue_free()
	elif Vector2i(x, y) == chunk:
		Global.music_player.stop()
		get_tree().paused = true
		$CutsceneBars.start()
		$EdgarName/AnimationPlayer.play("show")
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
		
		if Global.flags.has(MONOLOGUE_FLAG):
			echo_walker.dest_reached.connect($RepeatNoticeDelay.start)
		else:
			echo_walker.dest_reached.connect($NoticeDelay.start)

func notice(_ignored: Node) -> void:
	$AnimationPlayer.play("mongoose_notice")

func end_cutscene() -> void:
	$Mongoose.hide()
	$CutsceneBars.end()
	$EdgarName/AnimationPlayer.play("hide")
	
	var mongoose_boss: Node2D = MongooseBoss.instantiate()
	mongoose_boss.facing_right = !$Mongoose.flip_h
	mongoose_boss.global_position = $Mongoose.global_position
	get_parent().add_child(mongoose_boss)
	mongoose_boss.upgrade_pos = global_position + UPGRADE_OFFSET
	Global.echo.respawned.connect(func():
		failed.emit()
	, ConnectFlags.CONNECT_ONE_SHOT)
	mongoose_boss.completed.connect(on_completed)
	Global.play_music(boss_theme)
	Global.flags.set(MONOLOGUE_FLAG, true)
	
	get_tree().paused = false
	cutscene_over.emit()

func on_completed() -> void:
	Global.flags.set(COMPLETED_FLAG, 1)
	completed.emit()
