class_name Damage
extends Node

@export var damage := 4
@export var active := true

signal hit()

func emit_hit():
	hit.emit()
