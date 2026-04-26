extends Area2D

const MYCELIUM_MAP_POPUP := preload("res://menu/dialogue/small_upgrade/mycelium_map_get.tscn")
const FIRST_CHAT_FLAG := "sporemother_first_chat"
const MUSH_MEAL_FLAG := "has_mush_meal"
const MYCELIUM_MAP_FLAG := "has_mycelium_map"

func yes_chosen() -> void:
	if Global.flags.has(MUSH_MEAL_FLAG):
		$Dialogue/YesWithMushMeal.render()
	else:
		$Dialogue/Yes.render()

func on_talk() -> void:
	$NpcArrow.generic_pause()
	if !Global.flags.has(FIRST_CHAT_FLAG):
		$Dialogue/FirstChat.render()
		Global.flags.set(FIRST_CHAT_FLAG, true)
	elif Global.flags.get(MYCELIUM_MAP_FLAG, false):
		if Global.flags.has(MUSH_MEAL_FLAG):
			$Dialogue/TalkAgainWithMush.render()
		else:
			$Dialogue/TalkAgainWith.render()
	else:
		$Dialogue/TalkAgainWithout.render()

func remove_before_next(src) -> void:
	$AnimationPlayer.play("remove")
	$AnimationPlayer.animation_finished.connect(func(_anim_name):
		src.emit_next()
	, ConnectFlags.CONNECT_ONE_SHOT)

func give() -> void:
	Global.flags.set(MYCELIUM_MAP_FLAG, true)
	recalculate_health_bar()

func remove() -> void:
	Global.flags.set(MYCELIUM_MAP_FLAG, false)
	recalculate_health_bar()

func render_map_popup() -> void:
	var popup: TextBoxView = MYCELIUM_MAP_POPUP.instantiate()
	Global.camera.add_child(popup)
	popup.close_signaled.connect($Dialogue/YesTakeCare.render)

func recalculate_health_bar() -> void:
	Global.health_bar.recalculate_max_health()
	Global.health = Global.health
