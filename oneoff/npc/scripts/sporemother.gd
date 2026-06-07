extends Area2D

const CutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")

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
	
	var walker: Node2D = CutsceneWalker.instantiate()
	walker.x_destination = $CollisionShape2D.position.x
	walker.face_right_on_deletion = true
	walker.dest_reached.connect(func():
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
	)
	add_child(walker)

func remove_before_next(src) -> void:
	if Global.is_smol:
		$EchoAnim/AnimationPlayer.play("sync_smol")
	else:
		$EchoAnim/AnimationPlayer.play("sync_{0}".format([Global.weight]))
	$EchoAnim/AnimationPlayer.seek(0., true)
	
	$EchoAnim/AnimationPlayer.play("remove")
	$EchoAnim/AnimationPlayer.animation_finished.connect(func(_anim_name):
		src.emit_next()
	, ConnectFlags.CONNECT_ONE_SHOT)

func give_anim() -> void:
	if Global.is_smol:
		$EchoAnim/AnimationPlayer.play("sync_smol")
	else:
		$EchoAnim/AnimationPlayer.play("sync_{0}".format([Global.weight]))
	$EchoAnim/AnimationPlayer.seek(0., true)
	
	$EchoAnim/AnimationPlayer.play("give")

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

func hide_echo() -> void:
	Global.echo.hide()

func show_echo() -> void:
	Global.echo.show()

func recalculate_health_bar() -> void:
	Global.health_bar.recalculate_max_health()
	Global.health = Global.health
