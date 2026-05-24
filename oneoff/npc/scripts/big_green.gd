extends Area2D

@export var flag: String
@export var color_flower_parent: Node

signal opened()

func dialogue() -> void:
	$NpcArrow.generic_pause()
	if Global.flags.has(flag):
		$Dialogue/Repeat.render()
	else:
		Global.flags.set(flag, true)
		$Dialogue/FirstEncounter.render()

func do_open() -> void:
	opened.emit()
	for child in color_flower_parent.get_children():
		child.slow_try_open()
	$OpenTimer.start()
	$AnimationPlayer.play("open")
