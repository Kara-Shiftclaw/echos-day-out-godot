extends AnimatableBody2D

const DURATION_PER_SCREEN := 0.4
const DIST_TO_FALL := 24.

var in_air := false
var in_animation := false


func _process(_delta: float) -> void:
	if !in_animation and in_air and Global.echo.global_position.y > global_position.y + DIST_TO_FALL:
		on_activate()


func on_activate() -> void:
	in_animation = true
	$AnimationPlayer.play("wiggle")
	$ActivateArea/ActivateAreaShape.set_deferred("disabled", true)
	await get_tree().create_timer(0.3).timeout
	
	if !in_air:
		$WaveAnimationPlayer.play("hover")
	else:
		$WaveAnimationPlayer.play("RESET")
	
	var tween := create_tween()
	tween.tween_property(self, "position", Vector2(8., get_dest()), \
			DURATION_PER_SCREEN * get_parent().size.y / Util.ROOM_SIZE)
	tween.finished.connect(func():
		in_air = !in_air
		$ActivateArea/ActivateAreaShape.set_deferred("disabled", false)
		in_animation = false
	)

func get_dest() -> float:
	var parent: Control = get_parent()
	if in_air:
		return parent.size.y
	else:
		return 0.
