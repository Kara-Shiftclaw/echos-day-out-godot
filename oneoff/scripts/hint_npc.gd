extends Area2D

const USED_HINTS_FLAG := "used_hints"
const USED_TALK_FLAG := "used_talk"
const HINT_WEIGHT_FLAG := "hint_npc_weight"

@export var self_weight := 0:
	set(value):
		self_weight = value
		Global.flags[HINT_WEIGHT_FLAG] = value

var echo_inside := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and echo_inside and !get_tree().paused:
		get_tree().paused = true
		if Global.flags.get("hint_first_chat", false):
			load_main_menu()
		else:
			if Global.weight == Global.Weight.Blob:
				$Text/FirstChatBlob.render()
			else:
				$Text/FirstChat.render()

func load_main_menu() -> void:
	$Text/MainMenu/MultipleChoiceBox/Feed.enabled = Global.flags.get("food_on_hand", 0) > 0
	$Text/MainMenu/MultipleChoiceBox/Hint.enabled = Global.flags.get(USED_HINTS_FLAG, 0) < self_weight
	$Text/MainMenu.render()

func unpause() -> void:
	get_tree().paused = false
	Global.flags["hint_first_chat"] = true

func next_talk() -> void:
	$Text/NoTalk.render()

func next_feed() -> void:
	$Text/GiveFood.get_child(self_weight).render()

func next_hint() -> void:
	var hint: int = Global.flags.get(USED_HINTS_FLAG, 0)
	$Text/NoTalk.render()
	Global.flags[USED_HINTS_FLAG] = hint + 1

func inc_food() -> void:
	var food_on_hand: int = Global.flags.get("food_on_hand", 0)
	self_weight += 1
	Global.flags["food_on_hand"] = food_on_hand - 1

func entered(other: Node2D):
	if other is Echo:
		echo_inside = true

func exited(other: Node2D):
	if other is Echo:
		echo_inside = false
