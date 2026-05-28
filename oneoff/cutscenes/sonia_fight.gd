extends Node2D

var active := false

func start() -> void:
	print("Start")
	active = true
	get_tree().paused = true
	$CutsceneAnimationPlayer.play("start")

func sit_up(_text_box) -> void:
	$CutsceneAnimationPlayer.play("sit_up")

func begin_fight() -> void:
	get_tree().paused = false
	$CutsceneAnimationPlayer.play("begin_fight")
