extends Area2D

@export var flag: String
@export var post_sonia_repeat_flag: String
@export var color_flower_parent: Node

signal opened()

func dialogue() -> void:
	$NpcArrow.generic_pause()
	if Global.flags.has("sonia_completed"):
		if Global.flags.has(post_sonia_repeat_flag):
			$Dialogue/PostSoniaRepeat.render()
		else:
			Global.flags.set(post_sonia_repeat_flag, true)
			$Dialogue/PostSonia.render()
	else:
		if Global.flags.has(flag):
			$Dialogue/Repeat.render()
		else:
			Global.flags.set(flag, true)
			$Dialogue/FirstEncounter.render()
	
	if Global.flags.has("red_plant_open") and Global.flags.has("green_plant_open") \
			and Global.flags.has("blue_plant_open"):
		Global.journal_entries.set("small_plants", true)
		Global.journal_entries.set("big_plants", true)

func do_open() -> void:
	opened.emit()
	for child in color_flower_parent.get_children():
		child.slow_try_open()
	$OpenTimer.start()
	$AnimationPlayer.play("open")
