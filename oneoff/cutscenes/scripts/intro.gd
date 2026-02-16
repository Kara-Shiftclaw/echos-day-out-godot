extends Node2D

func _ready() -> void:
	if Global.flags.get("intro_cutscene", false):
		queue_free()
	else:
		Global.music_player.stop()
		Global.echo.hide()
		Global.health = Global.max_health
		get_tree().paused = true
		$CutsceneBars.start()
		$AnimationPlayer.play("cutscene")

func spawn_energy_orbs(amt: int) -> void:
	EnergyOrb.create_n(amt, $EnergyOrbCollector.global_position, $EnergyOrbCollector)

func conclude() -> void:
	Global.flags.set("intro_cutscene", true)
	Global.echo.show()
	Global.echo.global_position = $CutsceneEcho.global_position
	get_tree().paused = false
	$CutsceneBars.end()
	Global.music_player.play()
