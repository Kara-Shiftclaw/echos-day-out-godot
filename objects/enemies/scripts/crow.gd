extends Node2D

const Arrow := preload("res://objects/enemies/arrow.tscn")

@export var facing_right := false:
	set(value):
		facing_right = value
		if is_node_ready():
			sync_facing_right()

func _ready() -> void:
	sync_facing_right()

func sync_facing_right() -> void:
	$Crow.flip_h = facing_right

func start_fire_arrow() -> void:
	$AnimationPlayer.play("fire_arrow")

func fire_arrow() -> void:
	var arrow := Arrow.instantiate()
	arrow.moving_right = facing_right
	get_parent().add_child(arrow)
	arrow.global_position = global_position

func decision_point() -> void:
	if $EnemyManager.health > 0:
		if $PlayerDetectArea.get_overlapping_bodies().size() > 0:
			$AnimationPlayer.play("knife_attack")
		else:
			$AnimationPlayer.play("shoot_delay")

func reload() -> void:
	if $EnemyManager.health > 0:
		$AnimationPlayer.play("initial_shoot_delay")
		$AnimationPlayer.seek(0.)

func die() -> void:
	$AnimationPlayer.play("die")
	
func reset_knife() -> void:
	$KnifeArea/CollisionShape2D.set_deferred("disabled", true)
