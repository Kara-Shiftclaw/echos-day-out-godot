extends Area2D

var echo_inside := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and echo_inside and !get_tree().paused:
		get_tree().paused = true
		if Global.flags.get("hint_first_chat", false):
			$MainMenu/MultipleChoiceBox/Feed.enabled = Global.flags.get("food_on_hand", 0) > 0
			$MainMenu/MultipleChoiceBox/Hint.enabled = Global.flags.get("unused_hints", 0) > 0
			$MainMenu.render()
		else:
			if Global.weight == Global.Weight.Blob:
				$FirstChatBlob.render()
			else:
				$FirstChat.render()

func unpause() -> void:
	get_tree().paused = false
	Global.flags["hint_first_chat"] = true

func next_talk() -> void:
	$NoTalk.render()

func entered(other: Node2D):
	if other is Echo:
		echo_inside = true

func exited(other: Node2D):
	if other is Echo:
		echo_inside = false
