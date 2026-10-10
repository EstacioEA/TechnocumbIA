extends Node2D

const POT_ROOM := Rect2(880.0, 16.0, 288.0, 224.0)
const POT_ZONE := Rect2(944.0, 72.0, 112.0, 96.0)
const GATE_POSITION := Vector2(920.0, 220.0)
const GATE_SIZE := Vector2(20.0, 80.0)

const ROOM_BORDER := Color("#E38452")
const POT_COLOR := Color("#F6B951")
const POT_INNER := Color("#76412E")
const GATE_CLOSED := Color("#B62A2A")
const GATE_OPEN := Color("#73B161")
const LABEL_COLOR := Color("#EDCA96")

var _last_gate_open := false

func _ready() -> void:
	z_index = 2
	_last_gate_open = _is_gate_open()
	queue_redraw()

func _process(_delta: float) -> void:
	var gate_open := _is_gate_open()
	if gate_open != _last_gate_open:
		_last_gate_open = gate_open
		queue_redraw()

func _draw() -> void:
	draw_rect(POT_ROOM, ROOM_BORDER, false, 5.0)
	draw_rect(POT_ZONE, Color(POT_COLOR, 0.16), true)
	_draw_pot()
	_draw_gate()
	draw_string(ThemeDB.fallback_font, Vector2(900.0, 42.0), "TORRE: SALA DE LA OLLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, LABEL_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(918.0, 62.0), "OBJETIVO: OLLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, LABEL_COLOR)

func _draw_pot() -> void:
	var center := POT_ZONE.get_center()
	draw_circle(center, 38.0, POT_INNER)
	draw_circle(center, 34.0, POT_COLOR)
	draw_arc(center, 34.0, 0.0, TAU, 32, POT_INNER, 4.0)
	draw_line(center + Vector2(-24.0, 24.0), center + Vector2(-16.0, 44.0), POT_INNER, 5.0)
	draw_line(center + Vector2(24.0, 24.0), center + Vector2(16.0, 44.0), POT_INNER, 5.0)
	draw_string(ThemeDB.fallback_font, center + Vector2(-23.0, 6.0), "OLLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#21161E"))

func _draw_gate() -> void:
	var gate_color := GATE_OPEN if _last_gate_open else GATE_CLOSED
	if _last_gate_open:
		draw_line(GATE_POSITION + Vector2(0.0, -GATE_SIZE.y * 0.5), GATE_POSITION + Vector2(0.0, GATE_SIZE.y * 0.5), gate_color, 5.0)
	else:
		draw_rect(Rect2(GATE_POSITION - GATE_SIZE * 0.5, GATE_SIZE), Color(gate_color, 0.35), true)
		draw_line(GATE_POSITION - Vector2(0.0, GATE_SIZE.y * 0.5), GATE_POSITION + Vector2(0.0, GATE_SIZE.y * 0.5), gate_color, 5.0)
	draw_string(ThemeDB.fallback_font, Vector2(932.0, 214.0), "ENTRADA BESTIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, LABEL_COLOR)
	draw_string(ThemeDB.fallback_font, Vector2(932.0, 230.0), "ESTADO: %s" % ("ABIERTA" if _last_gate_open else "CERRADA"), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, gate_color)

func _is_gate_open() -> bool:
	var map := get_parent()
	return map != null and map.has_method("is_beast_gate_open") and map.is_beast_gate_open()
