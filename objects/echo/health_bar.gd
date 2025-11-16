extends Node2D

const PIXEL_WIDTH = 126.
const HEALTH_BAR_END_WIDTH = 4

@export var echo: Echo
@export var end_frame := 0:
	set(value):
		if end_frame != value:
			end_frame = value
			apply_end_frame()
var end_trunc := 0:
	set(value):
		if end_trunc != value:
			end_trunc = value
			apply_end_frame()

func _ready() -> void:
	if echo == null:
		push_error("Echo not set for health bar!")

func _process(_delta: float) -> void:
	if echo != null:
		var health_ratio := echo.health / echo.max_health
		var health_bar_w := floori(PIXEL_WIDTH * health_ratio)
		var health_bar_px := 1 + health_bar_w
		$HealthBarEnd.position.x = health_bar_px
		$HealthBarPrimary.offset_right = clamp(health_bar_px - HEALTH_BAR_END_WIDTH, 0., 128.)
		
		if health_bar_w < HEALTH_BAR_END_WIDTH:
			self.end_trunc = HEALTH_BAR_END_WIDTH - health_bar_w
		else:
			self.end_trunc = 0

func apply_end_frame():
	var x_ofs = 16 + (end_frame * HEALTH_BAR_END_WIDTH) + end_trunc
	var width = HEALTH_BAR_END_WIDTH - end_trunc
	$HealthBarEnd.region_rect.position.x = x_ofs
	$HealthBarEnd.region_rect.size.x = width
	$HealthBarEnd.offset.x = -2 + (end_trunc / 2.)
