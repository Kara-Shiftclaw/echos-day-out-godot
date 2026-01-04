extends StaticBody2D

const NormalHedgehog := preload("res://objects/enemies/hedgehog.tscn")

func begin_shatter() -> void:
	$AnimationPlayer.play("shatter")

func shatter() -> void:
	var normal_hedgehog: Node2D = NormalHedgehog.instantiate()
	get_parent().call_deferred("add_child", normal_hedgehog)
	normal_hedgehog.ready.connect(func() -> void:
		normal_hedgehog.global_position = global_position
		normal_hedgehog.temporary = true
	, ConnectFlags.CONNECT_ONE_SHOT)

func play_idle() -> void:
	if $EnemyManager.health > 0:
		$AnimationPlayer.play("idle")
