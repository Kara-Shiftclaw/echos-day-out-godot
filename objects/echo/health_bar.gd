class_name HealthBar
extends Node2D

const PIXEL_WIDTH = 126.
const HEALTH_BAR_END_WIDTH = 4

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
	Global.health_bar = self
	Global.echo_health_changed.connect(recalculate_health_bar)

func recalculate_health_bar(health: float) -> void:
	var health_ratio := health / Global.max_health
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
