class_name EnergyOrb
extends CharacterBody2D

const SCENE := preload("res://objects/energy_orb.tscn")
const ACCELERATION := 1500.

@export var target: Node2D
var speed := -200.

static func create_n(num: int, global_pos: Vector2, group_target: Node2D):
	await group_target.get_tree().process_frame
	for i in range(num):
		var orb: EnergyOrb = SCENE.instantiate()
		group_target.get_parent().add_child(orb)
		orb.target = group_target
		var scatter := Vector2(randf_range(-2., 2.), randf_range(-2., 2.))
		orb.global_position = global_pos + scatter

func _physics_process(delta: float) -> void:
	var movement_delta := target.global_position - global_position
	speed += ACCELERATION * delta
	velocity = movement_delta.normalized() * speed
	var collision := move_and_collide(velocity * delta)
	if collision != null:
		var collider = collision.get_collider()
		if collider is Echo:
			Global.health += 1
		queue_free()
