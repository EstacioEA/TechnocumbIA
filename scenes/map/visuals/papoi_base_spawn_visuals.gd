extends Node2D

const ATTACKER_BASE := Rect2(32.0, 280.0, 320.0, 240.0)
const DEFENDER_BASE := Rect2(1040.0, 496.0, 224.0, 224.0)
const BASE_BORDER := Color("#E38452")
const ATTACKER_COLOR := Color("#B62A2A", 0.28)
const DEFENDER_COLOR := Color("#2E9CC1", 0.28)
const SPAWN_COLOR := Color("#F6B951")
const PAPA_COLOR := Color("#D5993F")
const BEAST_COLOR := Color("#85333D")

func _ready() -> void:
	z_index = 1
	queue_redraw()

func _draw() -> void:
	_draw_base(ATTACKER_BASE, ATTACKER_COLOR, "BASE ATACANTE")
	_draw_base(DEFENDER_BASE, DEFENDER_COLOR, "BASE DEFENSORA")
	_draw_spawn_group("AttackerSpawns", SPAWN_COLOR, "A")
	_draw_spawn_group("DefenderSpawns", SPAWN_COLOR, "D")
	_draw_special_spawn("SpecialSpawns/PapaSpawn", PAPA_COLOR, "PAPA")
	_draw_special_spawn("SpecialSpawns/BeastSpawn", BEAST_COLOR, "BESTIA")

func _draw_base(rectangle: Rect2, fill: Color, label: String) -> void:
	draw_rect(rectangle, fill, true)
	draw_rect(rectangle, BASE_BORDER, false, 4.0)
	draw_string(ThemeDB.fallback_font, rectangle.position + Vector2(8.0, 24.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#EDCA96"))

func _draw_spawn_group(group_name: String, color: Color, prefix: String) -> void:
	var group := get_parent().get_node_or_null(group_name) as Node2D
	if group == null:
		return
	for index in group.get_child_count():
		var marker := group.get_child(index) as Marker2D
		if marker == null:
			continue
		var position := marker.position
		draw_circle(position, 14.0, Color(color, 0.22))
		draw_circle(position, 8.0, color)
		draw_string(ThemeDB.fallback_font, position + Vector2(12.0, 5.0), "%s%d" % [prefix, index + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#21161E"))

func _draw_special_spawn(path: String, color: Color, label: String) -> void:
	var marker := get_parent().get_node_or_null(path) as Marker2D
	if marker == null:
		return
	draw_circle(marker.position, 16.0, Color(color, 0.25))
	draw_circle(marker.position, 10.0, color)
	draw_string(ThemeDB.fallback_font, marker.position + Vector2(14.0, 5.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#EDCA96"))
