extends Player

const MAX_SPEED: float = Echo.SPEED_MAP[Global.Weight.Thin]
const ACCELERATION: float = Echo.ACCELERATION_MAP[Global.Weight.Thin]
const JUMP_VELOCITY: float = Echo.JUMP_VELOCITY_MAP[Global.Weight.Obese]
const JUMP_TIME: float = 5.5 * 8. * -JUMP_VELOCITY
const GRAVITY := Echo.GRAVITY

func sync_facing_right() -> void:
	$Sprite2D.flip_h = !facing_right

func set_anim(anim_name: String) -> bool:
	var prev_anim: String = $AnimationPlayer.current_animation
	if $AnimationPlayer.has_animation(anim_name):
		$AnimationPlayer.play(anim_name)
		return prev_anim != anim_name
	else:
		push_error("Asked to play anim ", anim_name, ", which smol Echo does not have")
		return false

func anim_seek(seconds := 0., update := false) -> void:
	$AnimationPlayer.seek(seconds, update)
