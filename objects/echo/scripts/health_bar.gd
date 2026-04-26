class_name HealthBar
extends Node2D

const HEALTH_POINT_WIDTH := 3
const HEALTH_BAR_END_WIDTH := 2
const HEALTH_BAR_LEFT_END := 3
const NORMAL_RIGHT_END_REGION_X := 6
const DANGER_RIGHT_END_REGION_X := 20
const DANGER_HEALTH := 6
const END_HEALTH := 3
const DIVIDER_WIDTH := 2

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
	recalculate_max_health()

func recalculate_max_health() -> void:
	var max_health := Global.max_health
	var mush_max_health := Global.max_health_mush_adjusted()
	if max_health == 1:
		$Back/Divider.hide()
		$Back/PrimaryArea.hide()
		$Back/LeftEnd.hide()
		$Back/RightEnd.hide()
		$Back/OneHp.show()
		$Back/DangerArea.offset_right = 0
		$Back/MushCurse.hide()
	elif max_health <= DANGER_HEALTH + 1:
		$Back/Divider.hide()
		$Back/PrimaryArea.hide()
		$Back/LeftEnd.show()
		$Back/RightEnd.show()
		$Back/OneHp.hide()
		
		var danger_right := clampf(max_health * HEALTH_POINT_WIDTH - END_HEALTH * 2, 0, 128)
		$Back/DangerArea.offset_right = danger_right
		$Back/RightEnd.position.x = danger_right
		recalculate_mush_curse(max_health, mush_max_health)
	else:
		$Back/Divider.show()
		$Back/PrimaryArea.show()
		$Back/LeftEnd.show()
		$Back/RightEnd.show()
		$Back/OneHp.hide()
		
		var danger_right := DANGER_HEALTH * HEALTH_POINT_WIDTH - END_HEALTH
		var divider_right := danger_right + DIVIDER_WIDTH
		var primary_right := danger_right + (max_health - DANGER_HEALTH) * HEALTH_POINT_WIDTH - END_HEALTH
		$Back/DangerArea.offset_right = danger_right
		$Back/Divider.position.x = danger_right
		$Back/PrimaryArea.offset_left = divider_right
		$Back/PrimaryArea.offset_right = primary_right
		$Back/RightEnd.position.x = primary_right
		recalculate_mush_curse(max_health, mush_max_health)

func recalculate_health_bar(health: float) -> void:
	if health < 1:
		$HealthBarEnd.hide()
		$HealthBarPrimary.offset_right = 0
	else:
		print(floori(health))
		$HealthBarEnd.show()
		var health_bar_w := HEALTH_POINT_WIDTH * floori(health)
		$HealthBarEnd.position.x = health_bar_w + HEALTH_BAR_LEFT_END
		$HealthBarPrimary.offset_right = clamp(health_bar_w - HEALTH_BAR_END_WIDTH + HEALTH_BAR_LEFT_END, 0., 128.)
		
		if health_bar_w < HEALTH_BAR_END_WIDTH:
			self.end_trunc = HEALTH_BAR_END_WIDTH - health_bar_w
		else:
			self.end_trunc = 0

func recalculate_mush_curse(max_health: float, mush_max_health: float) -> void:
	if !Global.has_mush_curse() or max_health == mush_max_health:
		$Back/MushCurse.hide()
	else:
		$Back/MushCurse.show()
		var health_difference := max_health - mush_max_health
		var mush_end: Sprite2D = $Back/MushCurse/MushEnd
		var mush_end_w := (health_difference - 1) * HEALTH_POINT_WIDTH
		var mush_pos: float = $Back/RightEnd.position.x - mush_end_w + HEALTH_POINT_WIDTH
		mush_end.region_rect.size.x = mush_end_w
		mush_end.position.x = mush_pos
		$Back/MushCurse/MushTip.position.x = mush_pos

func apply_end_frame():
	var x_ofs = 12 + (end_frame * HEALTH_BAR_END_WIDTH) + end_trunc
	var width = HEALTH_BAR_END_WIDTH - end_trunc
	$HealthBarEnd.region_rect.position.x = x_ofs
	$HealthBarEnd.region_rect.size.x = width
	$HealthBarEnd.offset.x = -1 + (end_trunc / 2.)
