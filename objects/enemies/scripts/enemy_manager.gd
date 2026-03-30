extends Node

@export var max_health := 4
@export var energy_per_damage := 0.25
@export var energy_on_death := 2
@export var journal_entry := ""
@export var animation_player: AnimationPlayer
@export var reset_animation := &"RESET"
@export var parent_save_properties: Array[String] = [
	"position",
]
@export var play_death_sound := true

var saved_properties: Dictionary

var health: int
var energy_cache := 0.
var chunk: Vector2i
var post_load_frame: bool

signal hit()
signal die()
signal hit_after_death()
signal respawn()
signal chunk_entered()
signal chunk_entered_alive()
signal chunk_left()

func _ready() -> void:
	health = max_health
	var parent: Node2D = get_parent()
	parent.set_process(false)
	for property in parent_save_properties:
		saved_properties[property] = parent.get(property)
	Global.save.connect(func() -> void:
		health = max_health
		if animation_player != null:
			animation_player.play(reset_animation)
			animation_player.seek(0., true)
		respawn.emit()
	)
	chunk = Vector2i(floori(parent.global_position.x / Util.ROOM_SIZE), floori(parent.global_position.y / Util.ROOM_SIZE))
	Global.chunk_loaded.connect(func(cx: int, cy: int) -> void:
		if chunk.x == cx and chunk.y == cy:
			chunk_entered.emit()
			if health > 0:
				chunk_entered_alive.emit()
			parent.process_mode = Node.PROCESS_MODE_INHERIT
		elif parent.can_process():
			chunk_left.emit()
			parent.process_mode = Node.PROCESS_MODE_DISABLED
	)

func on_hit(attacker: Node2D) -> void:
	var maybe_damage = attacker.get_node_or_null("Damage")
	if maybe_damage != null and maybe_damage.active:
		take_damage(maybe_damage)

func take_damage_from_path(path: NodePath) -> void:
	var maybe_damage = get_node_or_null(path)
	if maybe_damage != null and maybe_damage is Damage and maybe_damage.active:
		take_damage(maybe_damage)

func take_damage(damage: Damage) -> void:
	var damage_amt := damage.damage
	if damage_amt > 0:
		if health <= 0:
			hit_after_death.emit()
		else:
			print("Took {0} damage, at {1} health".format([damage_amt, health]))
			health -= damage_amt
			hit.emit()
			energy_cache += damage_amt * energy_per_damage
			damage.emit_hit()
			if energy_cache >= 1.:
				var energy_to_send := floori(energy_cache)
				EnergyOrb.create_n(energy_to_send, get_parent().global_position, Global.echo)
				energy_cache -= energy_to_send
			
			if health <= 0:
				die.emit()
				if play_death_sound:
					$EnemyDieSound.play()
				EnergyOrb.create_n(energy_on_death, get_parent().global_position, Global.echo)
				if journal_entry != "":
					Global.journal_entries.set(journal_entry, true)

func reset() -> void:
	post_load_frame = true
	if health > 0:
		health = max_health
	var parent := get_parent()
	for property in saved_properties:
		parent.set(property, saved_properties[property])

func manage_post_load_frame():
	post_load_frame = true
	await get_tree().process_frame
	post_load_frame = false
