class_name Damage
extends Node

@export var damage := 4
@export var active := true
@export var ignore_invin_frame := false

signal hit()

func emit_hit():
	hit.emit()

func disable():
	active = false
