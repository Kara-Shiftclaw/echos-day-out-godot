extends Node2D

@export var enemy_path: PackedScene
@export var facing_right := true

signal killed()


func fly_left() -> void:
	$AnimationPlayer.play("fly_left")

func fly_right() -> void:
	$AnimationPlayer.play("fly_right")

func summon() -> void:
	var enemy: Node2D = enemy_path.instantiate()
	if "facing_right" in enemy:
		enemy.facing_right = facing_right
	else:
		enemy.scale.x = Util.sign(!facing_right)

	var enemy_manager: EnemyManager = enemy.get_node("EnemyManager")
	enemy_manager.die.connect(killed.emit)
	Global.chunk_loaded.connect(enemy.queue_free.unbind(2))
	
	add_child(enemy)
	enemy_manager.chunk_entered.emit()
	enemy_manager.chunk_entered_alive.emit()
