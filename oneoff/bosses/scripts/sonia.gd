extends CharacterBody2D

const DustCloud := preload("res://oneoff/bosses/sonia/dust_cloud.tscn")

func start() -> void:
	var dust_cloud: Node2D = DustCloud.instantiate()
	get_parent().add_child(dust_cloud)
	dust_cloud.global_position = global_position
