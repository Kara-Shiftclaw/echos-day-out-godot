@tool
extends Area2D

enum LockColor {
	Red = 0,
	Orange = 1,
	Green = 2,
	Yellow = 3,
}

const BackgroundTiles := preload("res://oneoff/background/scripts/background_tiles.gd")

@export var background_tiles: BackgroundTiles
@export var lock_color := LockColor.Red:
	set(value):
		lock_color = value
		sync_lock_color()
@onready var fail_txt: AbstractTextScript = $TextScriptBase

func _ready() -> void:
	if !Engine.is_editor_hint():
		background_tiles.add_node_to_background($Back.duplicate(), $Back.global_position)
		background_tiles.add_node_to_background($BackReturn.duplicate(), $BackReturn.global_position)
		$BackReturn.queue_free()
		init_fail_txt()
	sync_lock_color()

func activated() -> void:
	if Global.flags.get(flag(), false) or background_tiles.in_background:
		var going_in := !background_tiles.in_background
		background_tiles.in_background = going_in
		$AnimationPlayer.play("open")
	else:
		fail_txt.start()

func sync_lock_color() -> void:
	if is_node_ready():
		$LockColor.frame = lock_color as int

func flag() -> String:
	var color_name: String = LockColor.find_key(lock_color)
	return "{0}_catseye".format([color_name.to_lower()])

func init_fail_txt() -> void:
	var textbox_scene := fail_txt.default_textbox_scene
	fail_txt.set_script(FailTxt)
	fail_txt.default_textbox_scene = textbox_scene


class FailTxt:
	extends AbstractTextScript
	
	func script() -> void:
		await txt("CATSEYE_DOOR_FAIL")
