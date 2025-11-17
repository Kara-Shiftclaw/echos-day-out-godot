extends VisibleOnScreenEnabler2D

@export var max_health := 4
@export var energy_per_damage := 0.25
@export var energy_on_death := 2
@export var animation_player: AnimationPlayer
@export var reset_animation := &"RESET"
@export var parent_save_properties: Array[String] = [
	"position",
]

var saved_properties: Dictionary

var health: int
var energy_cache := 0.

signal hit()
signal die()
signal hit_after_death()

func _ready() -> void:
	health = max_health
	var parent := get_parent()
	for property in parent_save_properties:
		saved_properties[property] = parent.get(property)
	SaveGlobal.save.connect(func() -> void:
		health = max_health
		if animation_player != null:
			animation_player.play(reset_animation)
	)

func on_hit(attacker: Node2D) -> void:
	var maybe_damage = attacker.get_node_or_null("Damage")
	if maybe_damage != null:
		take_damage(maybe_damage.damage)
		
func take_damage(damage: int) -> void:
	if damage > 0:
		if health <= 0:
			hit_after_death.emit()
		else:
			print("Took {0} damage, at {1} health".format([damage, health]))
			health -= damage
			hit.emit()
			energy_cache += damage * energy_per_damage
			if energy_cache >= 1.:
				var energy_to_send := floori(energy_cache)
				print("Sending {0} energy".format([energy_to_send]))
				energy_cache -= energy_to_send
			
			if health <= 0:
				die.emit()
				print("On death, sending {0} energy".format([energy_on_death]))

func entered() -> void:
	if health > 0:
		health = max_health
		var parent := get_parent()
		for property in saved_properties:
			parent.set(property, saved_properties[property])
