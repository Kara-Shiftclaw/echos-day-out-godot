extends Node2D

var first_chat := false

func on_chat() -> void:
	$NpcArrow.generic_pause()
	if first_chat:
		$Repeat.render()
	else:
		$FirstChat.render()
		first_chat = true
