extends Area2D

@export var upgrade_pos := Vector2(0., 24.)

signal upgrade_collected()

func release() -> void:
	$AnimationPlayer.play("hit_l")

func on_hit() -> void:
	if Global.echo_is_right(self):
		$AnimationPlayer.play("hit_l")
	else:
		$AnimationPlayer.play("hit_r")
	$AnimationPlayer.seek(0., true)
	$AnimationPlayer.queue("idle")

func spawn_upgrade() -> void:
	var upgrade: Upgrade = Upgrade.instantiate()
	get_parent().call_deferred("add_child", upgrade)
	upgrade.move_from_to(global_position, upgrade_pos)
	upgrade.grant_double_jump = true
	upgrade.collected.connect(upgrade_collected.emit)
