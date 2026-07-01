extends HBoxContainer

const AbilityUsage := Accessibility.AbilityUsage

@export_custom(PROPERTY_HINT_ENUM, "fireball,double_jump,sprint,crush")
var ability_path: String

func _ready() -> void:
	var source: AbilityUsage = Accessibility.get(ability_path)
	match source:
		AbilityUsage.Grant:
			$Grant.set_pressed_no_signal(true)
		AbilityUsage.Default:
			$Default.set_pressed_no_signal(true)
		AbilityUsage.Revoke:
			$Revoke.set_pressed_no_signal(true)

func on_grant() -> void:
	Accessibility.set(ability_path, AbilityUsage.Grant)

func on_default() -> void:
	Accessibility.set(ability_path, AbilityUsage.Default)

func on_revoke() -> void:
	Accessibility.set(ability_path, AbilityUsage.Revoke)
