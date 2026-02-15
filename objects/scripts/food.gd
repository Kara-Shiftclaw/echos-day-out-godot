extends Area2D

const FOOD_ON_HAND_FLAG := "food_on_hand"
const FOOD_COLLECTED_FLAG := "food_collected"

const UpgradeGetScene := preload("res://menu/dialogue/small_upgrade/food_get.tscn")

func _ready() -> void:
	if Global.has_node_flag(self, "collected"):
		queue_free()

func entered(other: Node2D):
	if other is Echo:
		hide()
		if !other.is_on_floor():
			other.land_on_floor.connect(do_food_get)
		else:
			do_food_get()

func do_food_get():
	if Global.flags.has(FOOD_ON_HAND_FLAG):
		Global.flags[FOOD_ON_HAND_FLAG] += 1
		Global.flags[FOOD_COLLECTED_FLAG] += 1
	else:
		Global.flags[FOOD_ON_HAND_FLAG] = 1
		Global.flags[FOOD_COLLECTED_FLAG] = 1
	
	var upgrade_get_popup: TextBoxView = UpgradeGetScene.instantiate()
	Global.camera.add_child(upgrade_get_popup)
	upgrade_get_popup.close_signaled.connect(Global.unpause)
	
	Global.set_node_flag(self, "collected")
	get_tree().paused = true
	queue_free()
