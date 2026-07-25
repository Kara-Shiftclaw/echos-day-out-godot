extends AbstractTextScript

const QUEST_FLAG := "daniel_vore_quest_state"
const VORE_STATE := "VORE"
const JAIL_STATE := "JAIL"

@export var health_up: Node2D

func decide_start() -> void:
	var state = Global.flags.get(QUEST_FLAG, null)
	if state == VORE_STATE or state == JAIL_STATE:
		start()
	else: # Old dialogue system text (Sonia questline)
		get_parent().dialogue()

func script() -> void:
	var state = Global.flags.get(QUEST_FLAG, null)
	if state == VORE_STATE:
		await vore()
	elif state == JAIL_STATE:
		await jail()

func vore() -> void:
	if repeat():
		await txt_r("BIG_RED_VORE_R", 1, 4)
	else:
		await txt_r("BIG_RED_VORE", 1, 7)
		if is_instance_valid(health_up) and !Global.has_node_flag(health_up, "collected"):
			await txt("BIG_RED_VORE_8")
			health_up.gift_from_to($"../GiftFrom".global_position, $"../GiftTo".global_position)

func jail() -> void:
	if repeat():
		await txt_r("BIG_RED_JAIL_R", 1, 3)
	else:
		await txt_r("BIG_RED_JAIL", 1, 5)
