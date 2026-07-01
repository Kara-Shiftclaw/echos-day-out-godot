extends Node

enum AbilityUsage {
	Default,
	Grant,
	Revoke,
}

@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var fireball := AbilityUsage.Default
@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var double_jump := AbilityUsage.Default
@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var sprint := AbilityUsage.Default
@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var crush := AbilityUsage.Default
@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var max_hp_offset := 0
@export_custom(PROPERTY_USAGE_NO_EDITOR, "") var is_smol := false
