extends AbstractTextScript

func script() -> void:
	await txt("ANTI_SOFTLOCK")
	Global.health -= 999
