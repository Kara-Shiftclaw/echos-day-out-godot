extends Node2D

const BackgroundRenderer := preload("res://oneoff/background/scripts/background_renderer.gd")
const BackgroundTiles := preload("res://oneoff/background/scripts/background_tiles.gd")
const OFFSET := Vector2(-BackgroundRenderer.MAX_RADIUS, -BackgroundRenderer.MAX_RADIUS)

@export var background_renderer: BackgroundRenderer
@export var background_tiles: BackgroundTiles
@export var foreground_z_index := -101
@export var background_z_index := 0
var last_renderer_global_pos: Vector2

func _ready() -> void:
	background_renderer.draw.connect(queue_redraw)

func _process(_delta: float) -> void:
	if last_renderer_global_pos != background_renderer.global_position:
		queue_redraw()
		last_renderer_global_pos = background_renderer.global_position

func _draw() -> void:
	draw_texture(background_renderer.texture, background_renderer.global_position + OFFSET)
