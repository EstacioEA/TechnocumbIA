class_name PapoiEscapeExitIndicator
extends Node2D

signal escape_availability_changed(enabled: bool)

@export var closed_color := Color("#9AA4B2")
@export var active_color := Color("#73B161")
@export var panel_color := Color("#21161E")

var _escape_available := false
var _status_label: Label

func _ready() -> void:
	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.position = Vector2(-46.0, 38.0)
	_status_label.size = Vector2(160.0, 28.0)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 14)
	add_child(_status_label)
	_update_status()
	queue_redraw()

func set_escape_available(enabled: bool) -> void:
	if _escape_available == enabled:
		return
	_escape_available = enabled
	_update_status()
	queue_redraw()
	escape_availability_changed.emit(enabled)

func is_escape_available() -> bool:
	return _escape_available

func _update_status() -> void:
	if _status_label == null:
		return
	_status_label.text = "SALIDA ACTIVA" if _escape_available else "SALIDA CERRADA"
	_status_label.modulate = active_color if _escape_available else closed_color

func _draw() -> void:
	var color := active_color if _escape_available else closed_color
	draw_style_box(_panel_box(panel_color), Rect2(-58.0, -58.0, 184.0, 92.0))
	draw_rect(Rect2(-28.0, -22.0, 58.0, 56.0), color, false, 4.0)
	draw_arc(Vector2(1.0, -20.0), 29.0, PI, TAU, 16, color, 4.0, true)
	if _escape_available:
		var arrow := PackedVector2Array([
			Vector2(42.0, 5.0),
			Vector2(22.0, -10.0),
			Vector2(22.0, -3.0),
			Vector2(5.0, -3.0),
			Vector2(5.0, 13.0),
			Vector2(22.0, 13.0),
			Vector2(22.0, 20.0),
		])
		draw_colored_polygon(arrow, color)
	else:
		draw_line(Vector2(-14.0, -10.0), Vector2(15.0, 20.0), color, 5.0, true)
		draw_line(Vector2(15.0, -10.0), Vector2(-14.0, 20.0), color, 5.0, true)

func _panel_box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = 8
	box.corner_radius_top_right = 8
	box.corner_radius_bottom_left = 8
	box.corner_radius_bottom_right = 8
	box.border_color = Color("#E38452")
	box.set_border_width_all(2)
	return box
