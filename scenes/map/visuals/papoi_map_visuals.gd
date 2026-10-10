class_name PapoiMapVisuals
extends Node2D

const MAP_BOUNDS := Rect2(0.0, 0.0, 1280.0, 720.0)
const ROUTES := [
	Rect2(48.0, 302.0, 210.0, 190.0),
	Rect2(208.0, 292.0, 144.0, 92.0),
	Rect2(48.0, 120.0, 224.0, 80.0),
	Rect2(96.0, 194.0, 150.0, 82.0),
	Rect2(214.0, 164.0, 116.0, 92.0),
	Rect2(96.0, 260.0, 256.0, 50.0),
	Rect2(272.0, 120.0, 150.0, 470.0),
	Rect2(360.0, 292.0, 300.0, 86.0),
	Rect2(372.0, 194.0, 282.0, 88.0),
	Rect2(488.0, 224.0, 82.0, 150.0),
	Rect2(570.0, 210.0, 170.0, 300.0),
	Rect2(690.0, 292.0, 290.0, 86.0),
	Rect2(858.0, 258.0, 122.0, 82.0),
	Rect2(920.0, 110.0, 120.0, 230.0),
	Rect2(1000.0, 178.0, 84.0, 90.0),
	Rect2(1060.0, 286.0, 130.0, 100.0),
	Rect2(970.0, 342.0, 140.0, 100.0),
	Rect2(1030.0, 350.0, 115.0, 190.0),
	Rect2(730.0, 398.0, 300.0, 98.0),
	Rect2(940.0, 382.0, 142.0, 154.0),
	Rect2(1050.0, 310.0, 140.0, 125.0),
	Rect2(820.0, 490.0, 300.0, 130.0),
	Rect2(1100.0, 540.0, 180.0, 130.0),
	Rect2(1100.0, 380.0, 120.0, 240.0),
	Rect2(1130.0, 550.0, 124.0, 162.0),
]
const REFERENCE_MAP := preload("res://assets/maps/Mapa Base.jpeg")

const COLOR_BOUNDARY := Color("#21161E")
const COLOR_FOLIAGE_DARK := Color("#0E4F22")
const COLOR_FOLIAGE := Color("#397823")
const COLOR_FOLIAGE_LIGHT := Color("#629C2E")
const COLOR_ROUTE := Color("#D0A57C")
const COLOR_ROUTE_EDGE := Color("#B77D59")
const COLOR_WALL := Color("#76412E")
const COLOR_WALL_HIGHLIGHT := Color("#E38452")

var show_route_debug := false

func _ready() -> void:
	z_index = -1
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(REFERENCE_MAP, MAP_BOUNDS, false)
	if show_route_debug:
		_draw_routes()

func set_route_debug_visible(enabled: bool) -> void:
	show_route_debug = enabled
	queue_redraw()

func _draw_routes() -> void:
	for route in ROUTES:
		draw_rect(route, Color(COLOR_ROUTE, 0.16), true)
		draw_rect(route, Color(COLOR_ROUTE_EDGE, 0.65), false, 3.0)
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
