@tool
extends Sprite2D

const MAX_DIAMETER := 80
@warning_ignore("integer_division")
const MAX_RADIUS := MAX_DIAMETER / 2

@export_range(0, MAX_RADIUS) var radius := 32:
	set(value):
		radius = value
		draw_circle_image()
		queue_redraw()
var image: Image
var image_texture: ImageTexture

func _ready() -> void:
	image = Image.create_empty(MAX_DIAMETER, MAX_DIAMETER, true, Image.FORMAT_LA8)
	image_texture = ImageTexture.create_from_image(image)
	texture = image_texture
	draw_circle_image()

func draw_circle_image() -> void:
	if is_node_ready():
		image.fill_rect(Rect2i(0, 0, MAX_DIAMETER, MAX_DIAMETER), Color(0, 0, 0, 0))
		var rad_sq := radius * radius
		for xi in range(radius):
			var xi_sq := xi * xi
			for yi in range(radius):
				if xi_sq + (yi * yi) <= rad_sq:
					image.set_pixel(xi + MAX_RADIUS, yi + MAX_RADIUS, Color.WHITE)
					image.set_pixel(-xi + MAX_RADIUS - 1, yi + MAX_RADIUS, Color.WHITE)
					image.set_pixel(-xi + MAX_RADIUS - 1, -yi + MAX_RADIUS - 1, Color.WHITE)
					image.set_pixel(xi + MAX_RADIUS, -yi + MAX_RADIUS - 1, Color.WHITE)
		image_texture.set_image(image)

func grow() -> void:
	$AnimationPlayer.play("grow")

func shrink() -> void:
	$AnimationPlayer.play_backwards("grow")
