extends Area2D

const HEALTH_UP_COLLECTED_FLAG := "health_up_collected"

const UpgradeGetScene := preload("res://menu/dialogue/small_upgrade/health_up_get.tscn")

func _ready() -> void:
	if Global.has_node_flag(self, "collected"):
		queue_free()

func entered(other: Node2D):
	if other is Echo:
		hide()
		if !other.is_on_floor():
			other.land_on_floor.connect(do_health_up_get)
		else:
			do_health_up_get()

func do_health_up_get():
	if Global.flags.has(HEALTH_UP_COLLECTED_FLAG):
		Global.flags[HEALTH_UP_COLLECTED_FLAG] += 1
	else:
		Global.flags[HEALTH_UP_COLLECTED_FLAG] = 1
	Global.max_health += 3
	
	var upgrade_get_popup: TextBoxView = UpgradeGetScene.instantiate()
	Global.camera.add_child(upgrade_get_popup)
	upgrade_get_popup.close_signaled.connect(Global.unpause)
	
	Global.set_node_flag(self, "collected")
	get_tree().paused = true
	queue_free()
