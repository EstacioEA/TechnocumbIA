class_name PapoiMapVisuals
extends Node2D

const MAP_BOUNDS := Rect2(0.0, 0.0, 1280.0, 720.0)
const ROUTES := [
	Rect2(280.0, 280.0, 360.0, 160.0),
	Rect2(640.0, 260.0, 320.0, 160.0),
	Rect2(920.0, 120.0, 160.0, 200.0),
	Rect2(960.0, 400.0, 240.0, 240.0),
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

func _ready() -> void:
	z_index = -1
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(REFERENCE_MAP, MAP_BOUNDS, false)
	_draw_routes()

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
