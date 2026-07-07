extends Area2D

@export var is_default := false

func _ready() -> void:
	if is_default:
		if Global.echo.bound_node == null:
			Global.echo.bound_node = self
		else:
			push_warning("Multiple mirror saves are marked as default! ", get_path(), " was second")

func entered(other: Node2D) -> void:
	if other is Player:
		$AnimationPlayer.play("bound")
		other.bound_node = self
