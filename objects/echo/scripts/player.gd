@abstract class_name Player
extends CharacterBody2D

var facing_right := true:
	set(value):
		facing_right = value
		sync_facing_right()

var is_sprinting := false
@export var anim_priority := 0

@warning_ignore("unused_signal") signal land_on_floor()
@warning_ignore("unused_signal") signal respawned()

@abstract func sync_facing_right() -> void
@abstract func set_anim(anim_name: String) -> bool
@abstract func anim_seek(seconds := 0., update := false) -> void

func play_anim(anim_name: String, priority: int = 0) -> bool:
	if priority >= anim_priority:
		anim_priority = priority
		return set_anim(anim_name)
	else:
		return false
