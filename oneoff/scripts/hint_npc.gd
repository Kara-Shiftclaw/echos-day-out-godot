extends Area2D

const USED_HINTS_FLAG := "used_hints"
const USED_TALK_FLAG := "used_talk"
const HINT_WEIGHT_FLAG := "hint_npc_weight"
const HINT_FIREBALL := "hint_fireball"
const HINT_DOUBLE_JUMP := "hint_double_jump"
const HINT_SPRINT := "hint_sprint"
const HINT_CRUSH := "hint_crush"

@export var self_weight := 0:
	set(value):
		self_weight = value
		Global.flags[HINT_WEIGHT_FLAG] = value

var echo_inside := false

func _ready() -> void:
	self_weight = Global.flags.get(HINT_WEIGHT_FLAG, 0)
	$Sprite2D.frame = self_weight

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
	var talk: int = Global.flags.get(USED_TALK_FLAG, 0)
	if talk < self_weight:
		talk += 1
	$Text/Talk.get_child(talk).render()
	Global.flags[USED_TALK_FLAG] = talk

func next_feed() -> void:
	$Text/GiveFood.get_child(self_weight).render()

func next_hint() -> void:
	var hint: int = Global.flags.get(USED_HINTS_FLAG, 0)
	
	if needs_fireball():
		Global.flags[HINT_FIREBALL] = true
		$Text/Hint/Fireball.render()
	elif needs_double_jump():
		Global.flags[HINT_DOUBLE_JUMP] = true
		$Text/Hint/DoubleJump.render()
	elif needs_sprint():
		Global.flags[HINT_SPRINT] = true
		$Text/Hint/Sprint.render()
	elif needs_crush():
		Global.flags[HINT_CRUSH] = true
		$Text/Hint/Crush.render()
	else:
		$Text/Hint/NoMore.render()
	
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

func needs_fireball():
	return !Global.has_fireball and !Global.flags.has(HINT_FIREBALL)

func needs_double_jump():
	return !Global.has_double_jump and !Global.flags.has(HINT_DOUBLE_JUMP)

func needs_sprint():
	return !Global.has_sprint and !Global.flags.has(HINT_SPRINT)

func needs_crush():
	return !Global.has_crush and !Global.flags.has(HINT_CRUSH)
