extends AbstractTextScript

const CorvidFlyover := preload("res://objects/particle/scripts/multi_corvid_flyover.gd")
const UPGRADE_BOX_PATH := "res://menu/dialogue/view/textengine_upgrade.tscn"
const SLOW_BOX_PATH := "res://menu/dialogue/view/slow_text_box.tscn"
const CATSEYE_GET_TEXTURE := preload("res://assets/gfx/catseye_get.png")
const FLAG := "red_catseye"

@export var echo_dest: Node2D

@onready var cq: Sprite2D = get_parent()
@onready var cq_anim: AnimationPlayer = $"../AnimationPlayer"

signal shake_proceed


func _ready() -> void:
	if Global.flags.get(FLAG, false):
		get_parent().queue_free()

func script() -> void:
	await txt("RED_ARENA_CQ_1")
	var option_box := load_option_box()
	
	Global.echo.play_anim("walk", 99)
	Global.echo.anim_priority = 0
	var walker := CutsceneWalker.instantiate()
	walker.x_destination = echo_dest.position.x
	walker.face_right_on_deletion = true
	get_parent().add_child(walker)
	await walker.dest_reached
	
	await get_tree().create_timer(0.2).timeout
	Global.echo.hide()
	cq_anim.play("echo_" + str(Global.weight as int))
	cq_anim.seek(0., true)
	await get_tree().create_timer(0.5).timeout
	await txt("RED_ARENA_CQ_2")
	cq.frame = 1
	await txt("RED_ARENA_CQ_3")
	await opt_txt("RED_ARENA_CQ_4", [
		opt("RED_ARENA_POPUP_1"),
		opt("RED_ARENA_POPUP_2"),
	], option_box)
	cq.frame = 0
	cq_anim.play("echo_mad")
	await txt("RED_ARENA_CQ_5")
	cq_anim.play("wink")
	if Global.weight >= Global.Weight.Obese:
		await opt_txt("RED_ARENA_CQ_6_FAT", [
			opt("RED_ARENA_POPUP_3"),
		], option_box)
	else:
		await opt_txt("RED_ARENA_CQ_6_THIN", [
			opt("RED_ARENA_POPUP_3"),
		], option_box)
	await txt("RED_ARENA_CQ_7")
	cq_anim.play("toss")
	await cq_anim.animation_finished
	
	var upgrade_box := load_textbox(UPGRADE_BOX_PATH)
	upgrade_box.textbox.icon_texture = CATSEYE_GET_TEXTURE
	upgrade_box.textbox.region = Rect2(40. * Global.weight as int, 0., 40., 40.)
	await upgrade_box.txt(self, "RED_CATSEYE_GET")
	cq_anim.play("echo_mad")
	cq.frame = 0
	await txt("RED_ARENA_CQ_7_pt_5")
	cq.frame = 1
	await txt("RED_ARENA_CQ_8")
	
	var slow_box := load_textbox(SLOW_BOX_PATH)
	slow_box.txt(self, "RED_ARENA_CQ_9")
	get_tree().create_timer(2.).timeout.connect(func():
		shake_proceed.emit()
	)
	slow_box.textbox.close_signaled.connect(func():
		shake_proceed.emit()
	, ConnectFlags.CONNECT_ONE_SHOT)
	await shake_proceed
	cq_anim.play("echo_shake")
	await _self_impulse
	
	cq.frame = 2
	await txt("RED_ARENA_CQ_10")
	cq.frame = 4
	await txt("RED_ARENA_CQ_11")
	cq_anim.play("echo_mad")
	cq.frame = 0
	var choice = await opt_txt("RED_ARENA_CQ_12", [
		opt("RED_ARENA_POPUP_4"),
		opt("RED_ARENA_POPUP_5"),
		opt("RED_ARENA_POPUP_NIMBUS"),
		opt("RED_ARENA_POPUP_6"),
	], option_box)
	cq_anim.play("cq_shock")
	if choice == 2:
		await txt("RED_ARENA_CQ_NIMBUS")
	else:
		await txt("RED_ARENA_CQ_13")
	cq.frame = 4
	await txt("RED_ARENA_CQ_14")
	Global.echo.show()
	Global.flags.set(FLAG, true)
	cq_anim.play("escape")
