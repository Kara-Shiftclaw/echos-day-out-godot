@tool
class_name RandomAttackSelector
extends Node

@export var source: Node:
	set(value):
		source = value
		if calculate_source_enum() or value == null:
			notify_property_list_changed()
			update_configuration_warnings()
@export var attack_enum: String:
	set(value):
		attack_enum = value
		if calculate_source_enum() or value == null or value.is_empty():
			notify_property_list_changed()
			update_configuration_warnings()

var source_enum: Dictionary
var odds: Dictionary[String, int] = {}

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if source == null:
		warnings.append("\"source\" needs to be set to select an attack.")
	if attack_enum == null or attack_enum.is_empty():
		warnings.append("\"attack_enum\" needs to be set to select an attack.")
	return warnings

func _get_property_list() -> Array[Dictionary]:
	var enum_properties: Array[Dictionary] = []
	enum_properties.resize(source_enum.size())
	for enum_name in source_enum.keys():
		var enum_i: int = source_enum[enum_name]
		enum_properties[enum_i] = {
			"name": "{0}_odds".format([enum_name]),
			"type": TYPE_INT
		}
	return enum_properties

func calculate_source_enum() -> bool:
	if source != null and attack_enum != null:
		var maybe_source_enum = source.get(attack_enum)
		if maybe_source_enum != null:
			source_enum = maybe_source_enum
			return true
	return false

func _get(property: StringName) -> Variant:
	if property.ends_with("_odds") and source_enum != null:
		var enum_name := de_odds_name(property)
		return odds.get_or_add(enum_name, 1)
	return null

func _set(property: StringName, value: Variant) -> bool:
	if property.ends_with("_odds") and source_enum != null:
		var enum_name := de_odds_name(property)
		odds.set(enum_name, value)
		return true
	return false

func select_attack(excluded: Array[String]) -> String:
	var selection_odds := odds.duplicate()
	for excluded_str in excluded:
		selection_odds.erase(excluded_str)
	for odd_k in selection_odds.keys():
		if selection_odds[odd_k] == 0:
			selection_odds.erase(odd_k)
	if selection_odds.is_empty():
		return "NO_OP"
	
	var total_odds: int = selection_odds.values().reduce(func(accum, odd) -> int:
		return accum + odd
	, 0)
	var choice := randi_range(0, total_odds)
	for attack in selection_odds:
		choice -= selection_odds[attack]
		if choice <= 0:
			return attack
	return selection_odds.values().back()

func de_odds_name(odds_name: StringName) -> StringName:
	return odds_name.substr(0, odds_name.length() - 5)
