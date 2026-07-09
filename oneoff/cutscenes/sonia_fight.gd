extends Node2D

const COMPLETED_FLAG := "sonia_completed"
const MONOLOGUE_FLAG := "sonia_monologue"
const AWKWARD_WAIT_TIME := 0.5

@export var fight_song: AudioStream
var active := false
var normal_song: AudioStream

func _ready() -> void:
	if Global.flags.get(COMPLETED_FLAG, false):
		$CutsceneAnimationPlayer.play("load_completed")
	normal_song = Global.music_player.stream

func start() -> void:
	if !Global.flags.get(COMPLETED_FLAG, false):
		print("Start")
		active = true
		get_tree().paused = true
		Global.music_player.stop()
		if Global.flags.has(MONOLOGUE_FLAG):
			$CutsceneAnimationPlayer.play("truncated_start")
		else:
			Global.flags.set(MONOLOGUE_FLAG, true)
			$CutsceneAnimationPlayer.play("start")

func sit_up(_text_box) -> void:
	$CutsceneAnimationPlayer.play("sit_up")

func begin_fight() -> void:
	get_tree().paused = false
	Global.play_music(fight_song)
	$CutsceneAnimationPlayer.play("begin_fight")

func on_echo_death() -> void: 
	active = false
	Global.play_music(normal_song)
	$CutsceneAnimationPlayer.play("RESET")
	$OlhmAttack.reset()

func start_crashout() -> void:
	pause()
	Global.can_pause = false
	$Dialogue/Crashout.render()

func pause() -> void:
	get_tree().paused = true

func unpause() -> void:
	get_tree().paused = false

func shake_global_camera() -> void:
	Global.camera.screen_shake()

func set_completed() -> void:
	Global.can_pause = true
	Global.play_music(normal_song)
	Global.flags.set(COMPLETED_FLAG, true)
