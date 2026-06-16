extends Node2D

const SEEN_FLAG := "snowman_cutscene_seen"

signal show_title()

func _ready() -> void:
	if Global.flags.get(SEEN_FLAG, false):
		queue_free()
	$CutsceneBars.end()

func triggered() -> void:
	get_tree().paused = true
	#var no_artifact_region_y := 0 if Global.weight <= Global.Weight.Fat \
			#else 40 if Global.weight >= Global.Weight.MorObese else 20
	var no_artifact_region_y := 0.
	($EchoDies.region_rect as Rect2).position.y = no_artifact_region_y
	
	Global.flags.set(SEEN_FLAG, true)
	var cutscene_walker := CutsceneWalker.instantiate()
	cutscene_walker.x_destination = $EchoStopPos.position.x
	cutscene_walker.show_echo_on_relocate = false
	add_child(cutscene_walker)
	cutscene_walker.position.y = -9.
	cutscene_walker.load_alt_texture($EchoDies.texture, Rect2(0, no_artifact_region_y, 24. * 4., 20.))
	cutscene_walker.dest_reached.connect(on_echo_die)
	cutscene_walker.visible = false
	
	$AnimationPlayer.play("yoink")
	var hurt_move_tween := create_tween()
	$EchoDies.global_position.x = cutscene_walker.global_position.x
	var echo_x_after_yoink: float = $EchoDies.position.x + cutscene_walker.walk_speed * 0.1
	hurt_move_tween.tween_property($EchoDies, "position", Vector2(echo_x_after_yoink, 0.), 0.1)
	hurt_move_tween.tween_callback(func():
		print("Showing cutscene walker")
		cutscene_walker.show()
	)
	hurt_move_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func on_echo_die() -> void:
	Global.music_player.stop()
	$AnimationPlayer.play("echo_dies")

func reveal_nimbus() -> void:
	$AnimationPlayer.play("reveal_nimbus")

func toss_back() -> void:
	$AnimationPlayer.play("toss_back")

func walk_back_towards() -> void:
	var cutscene_walker := CutsceneWalker.instantiate()
	cutscene_walker.x_destination = $EchoWalkBackPos.position.x
	add_child(cutscene_walker)
	cutscene_walker.position = $EchoStopPos.position
	cutscene_walker.dest_reached.connect(func():
		$AnimationPlayer.play("look_before_end")
	)

func do_show_title() -> void:
	show_title.emit()

func end() -> void:
	get_tree().paused = false
	Global.music_player.play()
	queue_free()
