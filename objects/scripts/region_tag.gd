@tool
extends Node2D

enum Region {
	NotSelected,
	MtEcho,
	HeftwindHills,
	CharredCavern,
	Sporeways,
	VerdantCavern,
	PyritePlunge,
	DisphoticDepths,
	TreetopExpanse,
	ThievesRoad,
	BillowingHeights,
	Crater,
	Bramble,
	Home,
}

@export var which_region := Region.NotSelected:
	set(value):
		which_region = value
		if is_node_ready():
			var anim_name: String = Region.find_key(value)
			if $SelectionFrame.has_animation(anim_name):
				$SelectionFrame.play(anim_name)
			else:
				push_warning("Animation name ", anim_name, " not found")
@export var screens: Array[Vector2i] = []
@export var require_full_echo := false

func _ready() -> void:
	if !Engine.is_editor_hint():
		if Global.flags.has(Global.scene_flag_name("explored")):
			queue_free()
		hide()
		Global.chunk_loaded.connect(on_chunk_load)
	self.which_region = which_region

func on_chunk_load(cx: int, cy: int) -> void:
	if require_full_echo and !(Global.weight == Global.Weight.Blob or Global.is_smol):
		return
	
	for screen in screens:
		if screen.x == cx and screen.y == cy:
			$AnimationPlayer.play("show")
			Global.flags.set(Global.scene_flag_name("explored"), true)
