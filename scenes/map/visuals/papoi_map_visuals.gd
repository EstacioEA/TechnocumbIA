class_name PapoiMapVisuals
extends Node2D

const MAP_BOUNDS := Rect2(64.0, 64.0, 1152.0, 640.0)
const PLAYABLE_AREA := Rect2(80.0, 160.0, 1040.0, 448.0)
const ROUTES := [
	Rect2(208.0, 288.0, 272.0, 192.0),
	Rect2(720.0, 288.0, 272.0, 192.0),
	Rect2(480.0, 176.0, 240.0, 64.0),
	Rect2(480.0, 528.0, 240.0, 64.0),
]
const WALLS := [
	Rect2(80.0, 160.0, 1040.0, 128.0),
	Rect2(80.0, 480.0, 1040.0, 128.0),
	Rect2(80.0, 288.0, 128.0, 192.0),
	Rect2(992.0, 288.0, 128.0, 192.0),
]

const COLOR_BOUNDARY := Color("#21161E")
const COLOR_FOLIAGE_DARK := Color("#0E4F22")
const COLOR_FOLIAGE := Color("#397823")
const COLOR_FOLIAGE_LIGHT := Color("#629C2E")
const COLOR_ROUTE := Color("#D0A57C")
const COLOR_ROUTE_EDGE := Color("#B77D59")
const COLOR_WALL := Color("#76412E")
const COLOR_WALL_HIGHLIGHT := Color("#E38452")

func _ready() -> void:
	z_index = -1
	queue_redraw()

func _draw() -> void:
	draw_rect(MAP_BOUNDS, COLOR_BOUNDARY, true)
	draw_rect(PLAYABLE_AREA, COLOR_FOLIAGE_DARK, true)
	_draw_foliage_bands()
	_draw_walls()
	_draw_routes()

func _draw_foliage_bands() -> void:
	for band_index in range(7):
		var y := 176.0 + float(band_index) * 64.0
		var band := Rect2(96.0, y, 992.0, 32.0)
		draw_rect(band, COLOR_FOLIAGE if band_index % 2 == 0 else COLOR_FOLIAGE_LIGHT, true)
		for marker_index in range(12):
			var x := 112.0 + float(marker_index) * 88.0 + (32.0 if band_index % 2 == 0 else 0.0)
			draw_circle(Vector2(x, y + 16.0), 5.0, COLOR_FOLIAGE_DARK)

func _draw_walls() -> void:
	for wall in WALLS:
		draw_rect(wall, COLOR_WALL, true)
		draw_line(wall.position + Vector2(0.0, 8.0), Vector2(wall.end.x, wall.position.y + 8.0), COLOR_WALL_HIGHLIGHT, 4.0)
		draw_line(Vector2(wall.position.x, wall.end.y - 8.0), wall.end - Vector2(0.0, 8.0), COLOR_WALL_HIGHLIGHT, 4.0)

func _draw_routes() -> void:
	for route in ROUTES:
		draw_rect(route, COLOR_ROUTE, true)
		draw_rect(route, COLOR_ROUTE_EDGE, false, 4.0)
		_draw_route_markers(route)

func _draw_route_markers(route: Rect2) -> void:
	var horizontal := route.size.x >= route.size.y
	var marker_count := 6 if horizontal else 4
	for marker_index in range(marker_count):
		var ratio := (float(marker_index) + 1.0) / (float(marker_count) + 1.0)
		var marker_position := Vector2(
			lerp(route.position.x, route.end.x, ratio) if horizontal else route.get_center().x,
			route.get_center().y if horizontal else lerp(route.position.y, route.end.y, ratio)
		)
		draw_circle(marker_position, 3.0, COLOR_ROUTE_EDGE)
