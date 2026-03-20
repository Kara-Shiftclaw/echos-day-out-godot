extends Area2D

const Projectile := preload("res://objects/projectile/rook_projectile.tscn")
const PROJECTILE_FIRE_OFFSET := Vector2(-9, -13)

func start_fire() -> void:
	var closest: Node2D = null
	var closest_distance_sq := 999.
	var echo_pos := Global.echo.global_position
	for summon_spot: Node2D in get_tree().get_nodes_in_group("RookSummon"):
		var summon_distance_sq := summon_spot.global_position.distance_squared_to(echo_pos)
		if closest == null or summon_distance_sq < closest_distance_sq:
			closest = summon_spot
			closest_distance_sq = summon_distance_sq
	
	closest.fire()

func fire() -> void:
	var projectile: Node2D = Projectile.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + PROJECTILE_FIRE_OFFSET

func reload_alive() -> void:
	if !is_in_group("RookSummon"):
		add_to_group("RookSummon")
	$AnimationPlayer.play("idle")
	$AnimationPlayer.seek(0.)
	$Body/AnimationPlayer.play("idle")
	$Body/AnimationPlayer.seek(0.)

func unload() -> void:
	if is_in_group("RookSummon"):
		remove_from_group("RookSummon")
