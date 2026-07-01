extends HBoxContainer

func on_focus_entered() -> void:
	IconTab.get_current().grab_focus()
