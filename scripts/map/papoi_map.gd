class_name PapoiMap
extends Node2D

signal zone_entered(zone_name: String, body: Node2D)
signal zone_exited(zone_name: String, body: Node2D)

const MAP_BOUNDS := Rect2(64.0, 64.0, 1152.0, 640.0)
const ATTACKER_BASE := Vector2(144.0, 384.0)
const DEFENDER_BASE := Vector2(1136.0, 384.0)
const POT_ROOM_CENTER := Vector2(600.0, 384.0)
const ATTACKER_SPAWNS := [
	Vector2(120.0, 320.0),
	Vector2(120.0, 384.0),
	Vector2(120.0, 448.0),
]
const DEFENDER_SPAWNS := [
	Vector2(1080.0, 320.0),
	Vector2(1080.0, 384.0),
	Vector2(1080.0, 448.0),
]
const PAPA_SPAWN := Vector2(1010.0, 384.0)
const BEAST_SPAWN := Vector2(1040.0, 512.0)
const POT_ZONE := Rect2(544.0, 304.0, 112.0, 160.0)
const ESCAPE_ZONE := Rect2(80.0, 288.0, 128.0, 192.0)

var _beast_gate_open := false
var _zones: Dictionary = {}

func _ready() -> void:
	_create_boundaries()
	_create_zones()
	queue_redraw()

func get_spawn_points() -> Dictionary:
	return {
		"attackers": ATTACKER_SPAWNS.duplicate(),
		"defenders": DEFENDER_SPAWNS.duplicate(),
		"papa": PAPA_SPAWN,
		"beast": BEAST_SPAWN,
	}

func is_position_in_pot(position: Vector2) -> bool:
	return POT_ZONE.has_point(position)

func is_position_in_escape(position: Vector2) -> bool:
	return ESCAPE_ZONE.has_point(position)

func set_beast_gate_open(open: bool, host_authorized: bool) -> bool:
	if not host_authorized:
		return false
	_beast_gate_open = open
	var gate := get_node_or_null("BeastGate/CollisionShape2D") as CollisionShape2D
	if gate:
		gate.disabled = open
	queue_redraw()
	return true

func is_beast_gate_open() -> bool:
	return _beast_gate_open

func _create_boundaries() -> void:
	var boundaries := [
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.position.y, MAP_BOUNDS.size.x, 16.0),
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.end.y - 16.0, MAP_BOUNDS.size.x, 16.0),
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.position.y, 16.0, MAP_BOUNDS.size.y),
		Rect2(MAP_BOUNDS.end.x - 16.0, MAP_BOUNDS.position.y, 16.0, MAP_BOUNDS.size.y),
	]
	for index in boundaries.size():
		var body := StaticBody2D.new()
		body.name = "Boundary%d" % index
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = boundaries[index].size
		shape.shape = rectangle
		shape.position = boundaries[index].get_center()
		body.add_child(shape)
		add_child(body)

	var gate := StaticBody2D.new()
	gate.name = "BeastGate"
	var gate_shape := CollisionShape2D.new()
	gate_shape.name = "CollisionShape2D"
	var gate_rectangle := RectangleShape2D.new()
	gate_rectangle.size = Vector2(20.0, 128.0)
	gate_shape.shape = gate_rectangle
	gate_shape.position = Vector2(688.0, 384.0)
	gate.add_child(gate_shape)
	add_child(gate)

func _create_zones() -> void:
	_create_zone("PotZone", POT_ZONE)
	_create_zone("EscapeZone", ESCAPE_ZONE)

func _create_zone(zone_name: String, rectangle: Rect2) -> void:
	var area := Area2D.new()
	area.name = zone_name
	var shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = rectangle.size
	shape.shape = rectangle_shape
	shape.position = rectangle.get_center()
	area.add_child(shape)
	area.body_entered.connect(func(body: Node2D) -> void: zone_entered.emit(zone_name, body))
	area.body_exited.connect(func(body: Node2D) -> void: zone_exited.emit(zone_name, body))
	add_child(area)
	_zones[zone_name] = area

func _draw() -> void:
	draw_rect(MAP_BOUNDS, Color("#1c2638"), true)
	draw_rect(Rect2(80.0, 160.0, 1040.0, 448.0), Color("#273b4f"), true)
	draw_rect(Rect2(80.0, 288.0, 128.0, 192.0), Color("#244e5a"), true)
	draw_rect(Rect2(992.0, 288.0, 128.0, 192.0), Color("#563c50"), true)
	draw_rect(Rect2(480.0, 240.0, 240.0, 288.0), Color("#394456"), true)
	draw_rect(POT_ZONE, Color("#8e5e38"), true)
	draw_rect(ESCAPE_ZONE, Color("#2a8c76", 0.55), true)
	draw_line(Vector2(688.0, 320.0), Vector2(688.0, 448.0), Color("#f0c674"), 6.0)
	draw_string(ThemeDB.fallback_font, Vector2(92.0, 270.0), "BASE ATACANTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(990.0, 270.0), "BASE DEFENSORA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(530.0, 292.0), "SALA DE LA OLLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(540.0, 392.0), "OLLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#ffe6a7"))
	draw_string(ThemeDB.fallback_font, Vector2(702.0, 310.0), "ENTRADA BESTIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f0c674"))
