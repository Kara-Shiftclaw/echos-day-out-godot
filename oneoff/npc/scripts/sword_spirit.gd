extends Area2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")
const BladeGet := preload("res://menu/dialogue/small_upgrade/sword_blade_get.tscn")
const HiltGet := preload("res://menu/dialogue/small_upgrade/sword_hilt_get.tscn")

const FIRST_CHAT_FLAG := "sword_spirit_first_chat"
const SUMMON_OFFSET := Vector2(16., -24.)
const ECHO_STAND_OFFSET := -SUMMON_OFFSET.x

var starting_pos := Vector2.ZERO

func _ready() -> void:
	if Global.flags.has("sword_broken"):
		$Sprite2D.show()
		$CollisionShape2D.disabled = false
		happy()
	starting_pos = global_position

func talk() -> void:
	get_tree().paused = true
	
	var echo_walker: Node2D = EchoCutsceneWalker.instantiate()
	echo_walker.x_destination = ECHO_STAND_OFFSET
	echo_walker.face_right_on_deletion = true
	add_child(echo_walker)
	
	echo_walker.dest_reached.connect(func():
		if Global.flags.has(FIRST_CHAT_FLAG):
			$Text/Swap/MultipleChoiceBox2/YesBlade.enabled = Global.flags.has(Echo.SWORD_HILT_FLAG)
			$Text/Swap/MultipleChoiceBox2/YesHilt.enabled = Global.flags.has(Echo.SWORD_BLADE_FLAG)
			$Text/Swap.render()
		else:
			$Text/FirstChat.render()
			Global.flags.set(FIRST_CHAT_FLAG, true)
	)

func give_blade() -> void:
	var blade_get := BladeGet.instantiate()
	blade_get.close_signaled.connect($Text/Chosen.render)
	Global.camera.add_child(blade_get)
	
	Global.flags[Echo.SWORD_BLADE_FLAG] = true
	Global.flags.erase(Echo.SWORD_HILT_FLAG)

func give_hilt() -> void:
	var hilt_get := HiltGet.instantiate()
	hilt_get.close_signaled.connect($Text/Chosen.render)
	Global.camera.add_child(hilt_get)
	
	Global.flags[Echo.SWORD_HILT_FLAG] = true
	Global.flags.erase(Echo.SWORD_BLADE_FLAG)

func happy() -> void:
	$AnimationPlayer.play("happy")

func what() -> void:
	$AnimationPlayer.play("what")

func not_mad() -> void:
	$AnimationPlayer.play("not_mad")

func unpause() -> void:
	get_tree().paused = false
	$AnimationPlayer.play("happy")

func summon() -> void:
	global_position = Global.echo.global_position + SUMMON_OFFSET
	$AnimationPlayer.play("summon")

func fly_back_to_starting_pos() -> void:
	not_mad()
	var fly_back_tween := create_tween()
	fly_back_tween.tween_property(self, "global_position", starting_pos, 1.)
	fly_back_tween.tween_callback(func():
		happy()
		$CollisionShape2D.disabled = false
	)
