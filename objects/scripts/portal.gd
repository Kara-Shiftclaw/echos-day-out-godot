class_name Portal
extends Area2D

const EchoCutsceneWalker := preload("res://objects/echo/cutscene_walker.tscn")
const Choice := preload("res://menu/dialogue/model/choice.tscn")

enum Title {
	UndefinedTitle,
	MtEcho,
	Charwind,
	VerdantCavern,
	ThievesRoad,
	Crater,
	Bramble,
}

@export var title: Title
var echo_inside := false
var chosen_dest := Title.UndefinedTitle

func _ready() -> void:
	if Global.has_node_flag(self, "open"):
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("closed_idle")

func entered(other: Node2D):
	if other is Player:
		$UpArrow.show()
		echo_inside = true

func exited(other: Node2D):
	if other is Player:
		$UpArrow.hide()
		echo_inside = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") and echo_inside and Global.echo.is_on_floor():
		decide_text()

func decide_text() -> void:
	get_tree().paused = true
	if Global.has_node_flag(self, "open"):
		add_destinations()
		$Text/PortalUse.render()
	else:
		var has_injector := Global.flags.has("has_injector")
		var has_core: bool = Global.flags.get("core_on_hand", 0) > 0
		if has_injector and has_core:
			$Text/InjectPortalCore.render()
		elif has_injector:
			$Text/InjectNoPortalCore.render()
		elif has_core:
			$Text/PortalCoreNoInject.render()
		else:
			$Text/Nothing.render()

func unpause() -> void:
	get_tree().paused = false

func open() -> void:
	$AnimationPlayer.play("open")
	Global.set_node_flag(self, "open")
	Global.flags["core_on_hand"] -= 1
	Global.flags[InventoryMenu.used_flag(InventoryMenu.get_unused_portal_core())] = true
	Global.portals.set(title, get_scene_data())

func get_scene_data() -> Dictionary:
	return {
		"scene_file_path": get_tree().current_scene.scene_file_path,
		"path": get_path()
	}

func add_destinations() -> void:
	for dest_title in Global.portals:
		var dest_name := readable_title(dest_title)
		if !$Text/PortalUse/MultipleChoiceBox.has_node(dest_name) and dest_title != title:
			var choice: Node = Choice.instantiate()
			choice.choice_text = dest_name
			choice.enabled = true
			$Text/PortalUse/MultipleChoiceBox.add_child(choice)
			$Text/PortalUse/MultipleChoiceBox.move_child(choice, -2)
			choice.name = dest_name
			choice.chosen.connect(func():
				chosen_dest = dest_title
				begin_portal_animation()
			)

func begin_portal_animation() -> void:
	var echo_walker: Node2D = EchoCutsceneWalker.instantiate()
	echo_walker.x_destination = position.x
	echo_walker.face_right_on_deletion = true
	echo_walker.show_echo_on_relocate = false
	get_parent().add_child(echo_walker)
	
	if Global.flags.has("resize_injector"):
		$AnimationPlayer.play("use_xl")
	else:
		$AnimationPlayer.play("use")
	
	echo_walker.dest_reached.connect(func():
		Global.echo.hide()
		$PortalNoise.play()
		if echo_fits():
			if Global.is_smol:
				$Echo/AnimationPlayer.play("use_smol")
			else:
				$Echo/AnimationPlayer.play("use_{0}".format([int(Global.weight)]))
			$Echo/AnimationPlayer.animation_finished.connect(teleport)
		else:
			$Echo/AnimationPlayer.play("too_fat")
			$TooFatTimer.start()
	)

func teleport(_ignored) -> void:
	var transition := Echo.DeathScreen.instantiate()
	Global.camera.add_child(transition)
	transition.halfway.connect(func():
		Global.portal_to_new_stage(chosen_dest)
	)

func echo_fits() -> bool:
	return Global.is_smol or Global.flags.has("resize_injector") or Global.weight < Global.Weight.Blob

func too_fat_reset() -> void:
	unpause()
	Global.echo.show()
	$AnimationPlayer.play("too_fat_to_use")
	$Echo/AnimationPlayer.play("RESET")


static func from_legacy_title(legacy_title: String) -> Title:
	if legacy_title == "Char-Wind Pass":
		return Title.Charwind
	elif legacy_title == "Mt ???":
		return Title.MtEcho
	elif legacy_title == "Verdant Cavern":
		return Title.VerdantCavern
	else:
		return Title.UndefinedTitle

func readable_title(dest_title: Title) -> String:
	match dest_title:
		Title.MtEcho:
			return tr("PORTAL_LOC_MT_ECHO_BEFORE")
		Title.Charwind:
			return tr("PORTAL_LOC_CHARWIND")
		Title.VerdantCavern:
			return tr("REGION_NAME_VERDANT_CAVERN")
		Title.ThievesRoad:
			return tr("REGION_NAME_THIEVES_ROAD")
		Title.Crater:
			return tr("REGION_NAME_CRATER")
		Title.Bramble:
			return tr("REGION_NAME_BRAMBLE")
	return "UNKNOWN"
