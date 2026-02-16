extends Area2D

const CORE_ON_HAND_FLAG := "core_on_hand"
const CORE_COLLECTED_FLAG := "core_collected"

const UpgradeGetScene := preload("res://menu/dialogue/small_upgrade/portal_core_get.tscn")

func _ready() -> void:
	if Global.has_node_flag(self, "collected"):
		queue_free()

func entered(other: Node2D):
	if other is Echo:
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		if !other.is_on_floor():
			other.land_on_floor.connect(do_core_get)
		else:
			do_core_get()

func do_core_get():
	if Global.flags.has(CORE_ON_HAND_FLAG):
		Global.flags[CORE_ON_HAND_FLAG] += 1
		Global.flags[CORE_COLLECTED_FLAG] += 1
	else:
		Global.flags[CORE_ON_HAND_FLAG] = 1
		Global.flags[CORE_COLLECTED_FLAG] = 1
	
	var upgrade_get_popup: TextBoxView = UpgradeGetScene.instantiate()
	Global.camera.add_child(upgrade_get_popup)
	upgrade_get_popup.close_signaled.connect(Global.unpause)
	
	Global.set_node_flag(self, "collected")
	get_tree().paused = true
	queue_free()
