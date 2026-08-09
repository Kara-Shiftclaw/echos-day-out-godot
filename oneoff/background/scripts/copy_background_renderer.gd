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
	background_tiles.entered_background.connect(enter_background)
	background_tiles.exited_background.connect(exit_background)

func _process(_delta: float) -> void:
	if background_tiles.in_background and \
			last_renderer_global_pos != background_renderer.global_position:
		queue_redraw()
		last_renderer_global_pos = background_renderer.global_position

func _draw() -> void:
	if background_tiles.in_background:
		draw_texture(background_renderer.texture, background_renderer.global_position + OFFSET)


func enter_background() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	z_index = background_z_index

func exit_background() -> void:
	clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	z_index = foreground_z_index
