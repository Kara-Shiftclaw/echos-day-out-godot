extends Area2D

const UpgradeGetScene := preload("res://menu/dialogue/small_upgrade/journal_get.tscn")

func check_state() -> void:
	if Global.weight > Global.Weight.Thin:
		$AnimationPlayer.play("ate")
		if !Global.flags.has("has_journal"):
			$Journal.show()
		else:
			$CollisionShape2D.set_deferred("disabled", true)
	else:
		$AnimationPlayer.play("small_idle")

func entered(other: Node2D) -> void:
	if other is Echo:
		$Journal.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		if !other.is_on_floor():
			other.land_on_floor.connect(do_journal_get, ConnectFlags.CONNECT_ONE_SHOT)
		else:
			do_journal_get()

func do_journal_get() -> void:
	get_tree().paused = true
	var upgrade_get_popup: TextBoxView = UpgradeGetScene.instantiate()
	Global.camera.add_child(upgrade_get_popup)
	upgrade_get_popup.close_signaled.connect(Global.unpause)
	Global.flags["has_journal"] = true
