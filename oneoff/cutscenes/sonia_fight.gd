extends Node2D

const COMPLETED_FLAG := "sonia_completed"
const MONOLOGUE_FLAG := "sonia_monologue"

var active := false

func _ready() -> void:
	if Global.flags.get(COMPLETED_FLAG, false):
		queue_free()

func start() -> void:
	print("Start")
	active = true
	get_tree().paused = true
	if Global.flags.has(MONOLOGUE_FLAG):
		$CutsceneAnimationPlayer.play("truncated_start")
	else:
		Global.flags.set(MONOLOGUE_FLAG, true)
		$CutsceneAnimationPlayer.play("start")

func sit_up(_text_box) -> void:
	$CutsceneAnimationPlayer.play("sit_up")

func begin_fight() -> void:
	get_tree().paused = false
	$CutsceneAnimationPlayer.play("begin_fight")

func on_echo_death() -> void: 
	active = false
	$CutsceneAnimationPlayer.play("RESET")
	$OlhmAttack.reset()
