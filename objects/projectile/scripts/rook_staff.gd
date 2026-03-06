extends Node2D

const Projectile := preload("res://objects/projectile/rook_projectile.tscn")
const PROJECTILE_FIRE_OFFSET := Vector2(0, -11)

func fire() -> void:
	var projectile: Node2D = Projectile.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + PROJECTILE_FIRE_OFFSET

func reload() -> void:
	if !is_in_group("RookSummon"):
		add_to_group("RookSummon")

func unload() -> void:
	if is_in_group("RookSummon"):
		remove_from_group("RookSummon")
