extends Area2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")

const ECHO_X_OFFSET := -24.
const ECHO_Y_OFFSET := -9.
const FRAMES_PER_WEIGHT := 5

const USED_HINTS_FLAG := "used_hints"
const USED_TALK_FLAG := "used_talk"
const HINT_WEIGHT_FLAG := "hint_npc_weight"
const HINT_FIREBALL := "hint_fireball"
const HINT_DOUBLE_JUMP := "hint_double_jump"
const HINT_SPRINT := "hint_sprint"
const HINT_CRUSH := "hint_crush"

const WEIGHT_ARM_OFFSET := {
	0: -8.,
	1: -8.,
	2: -9.,
	3: -9.,
	4: -10.,
}
const WEIGHT_ARM_REGION_OFFSET := {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 10.,
}
const SCARF_OFFSET := {
	0: 5.,
	1: 5.,
	2: 6.,
	3: 6.,
	4: 6.,
}

@export var self_weight := 0:
	set(value):
		self_weight = value
		Global.flags[HINT_WEIGHT_FLAG] = value
		if is_node_ready():
			sync_frame()
@export var indiv_frame := 0:
	set(value):
		indiv_frame = value
		if is_node_ready():
			sync_frame()

var echo_inside := false
var loop_callback: Callable = do_nothing

func _ready() -> void:
	self_weight = Global.flags.get(HINT_WEIGHT_FLAG, 0)
	sync_frame()
	#$Sprite2D.frame = self_weight

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and echo_inside and !get_tree().paused:
		get_tree().paused = true
		$UpArrow.hide()
		
		var echo_walker: Node2D = EchoCutsceneWalker.instantiate()
		echo_walker.x_destination = position.x + ECHO_X_OFFSET
		echo_walker.face_right_on_deletion = true
		get_parent().add_child(echo_walker)
		echo_walker.dest_reached.connect(func():
			if Global.flags.get("hint_first_chat", false):
				load_main_menu()
			else:
				if Global.weight == Global.Weight.Blob:
					$Text/FirstChatBlob.render()
				else:
					$Text/FirstChat.render()
		)

func load_main_menu() -> void:
	$Text/MainMenu/MultipleChoiceBox/Feed.enabled = Global.flags.get("food_on_hand", 0) > 0
	$Text/MainMenu/MultipleChoiceBox/Hint.enabled = Global.flags.get(USED_HINTS_FLAG, 0) < self_weight
	$Text/MainMenu.render()

func unpause() -> void:
	$UpArrow.show()
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
	Global.journal_entries.set("affamae", true)

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
		Global.flags[USED_HINTS_FLAG] = 999
	
	Global.flags[USED_HINTS_FLAG] = hint + 1

func sync_frame() -> void:
	$Arm.position.x = WEIGHT_ARM_OFFSET[self_weight]
	$Arm.region_rect.position.y = WEIGHT_ARM_REGION_OFFSET[self_weight]
	$Scarf.position.x = SCARF_OFFSET[self_weight]
	$Body.frame = FRAMES_PER_WEIGHT * self_weight + indiv_frame

func inc_food() -> void:
	var food_on_hand: int = Global.flags.get("food_on_hand", 0)
	self.self_weight += 1
	Global.flags["food_on_hand"] = food_on_hand - 1
	Global.flags[InventoryMenu.used_flag(InventoryMenu.get_unused_food())] = true

func text_echo_grab_anim(text: Node, eat_loops: int = 1) -> void:
	var clamped_weight := maxi(Global.weight, Global.Weight.Obese)
	var echo_region_ofs := (clamped_weight - Global.Weight.Obese) * 20 + 20
	print("Echo region ofs ", echo_region_ofs)
	$EatingEcho.region_rect.position.y = echo_region_ofs
	
	$AnimationPlayer.play("echo_grab")
	Global.echo.hide()
	$EatingEcho.show()
	$EatingEcho.frame = 0
	loop_callback = func():
		if eat_loops > 0:
			text_play_anim(text, "eat", eat_loops)
		else:
			$AnimationPlayer.play("eat")
			text.next.emit()
			loop_callback = do_nothing

func text_play_anim(text: Node, anim_name: StringName, loops: int = 1) -> void:
	$AnimationPlayer.play(anim_name)
	loop_callback = func():
		text.next.emit()
		loop_callback = do_nothing
	for loop in range(0, loops - 1):
		var next_loop_callback := loop_callback
		loop_callback = func():
			loop_callback = next_loop_callback

func text_gain_anim(text: Node) -> void:
	$AnimationPlayer.play("gain")
	loop_callback = func():
		text.next.emit()
		inc_food()
		$AnimationPlayer.seek(0., true)
		loop_callback = do_nothing

func execute_loop_callback() -> void:
	if loop_callback != null:
		loop_callback.call()

func entered(other: Node2D):
	if other is Player:
		$UpArrow.show()
		echo_inside = true

func exited(other: Node2D):
	if other is Player:
		$UpArrow.hide()
		echo_inside = false

func show_real_echo() -> void:
	$EatingEcho.hide()
	Global.echo.show()

func needs_fireball():
	return !Global.has_fireball and !Global.flags.has(HINT_FIREBALL)

func needs_double_jump():
	return !Global.has_double_jump and !Global.flags.has(HINT_DOUBLE_JUMP)

func needs_sprint():
	return !Global.has_sprint and !Global.flags.has(HINT_SPRINT)

func needs_crush():
	return !Global.has_crush and !Global.flags.has(HINT_CRUSH)

static func do_nothing():
	pass
