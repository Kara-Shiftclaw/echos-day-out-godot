extends Node2D

@export var enemy_path: PackedScene
@export var facing_right := true

signal killed()
signal anim_finished()
signal summoned(enemy: Node2D)


func fly_left() -> void:
	$AnimationPlayer.play("fly_left")

func fly_right() -> void:
	$AnimationPlayer.play("fly_right")

func summon() -> void:
	if enemy_path == null:
		summoned.emit(null)
		return
	
	var enemy: Node2D = enemy_path.instantiate()
	var enemy_manager: EnemyManager = enemy.get_node_or_null("EnemyManager")
	if enemy_manager != null:
		if "facing_right" in enemy:
			enemy.facing_right = facing_right
		else:
			enemy.scale.x = Util.sign(!facing_right)
		
		enemy_manager.die.connect(killed.emit)
		Global.chunk_loaded.connect(enemy.queue_free.unbind(2))
		
		add_child(enemy)
		enemy_manager.chunk_entered.emit()
		enemy_manager.chunk_entered_alive.emit()
	else:
		add_child(enemy)
	summoned.emit(enemy)

func anim_finish() -> void:
	anim_finished.emit()
