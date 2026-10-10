class_name PapoiMap
extends Node2D

signal zone_entered(zone_name: String, body: Node2D)
signal zone_exited(zone_name: String, body: Node2D)

const MAP_BOUNDS := Rect2(0.0, 0.0, 1280.0, 720.0)
const ATTACKER_BASE := Vector2(190.0, 400.0)
const DEFENDER_BASE := Vector2(1140.0, 600.0)
const POT_ROOM_CENTER := Vector2(1000.0, 112.0)
const ATTACKER_SPAWNS := [
	Vector2(160.0, 340.0),
	Vector2(160.0, 400.0),
	Vector2(160.0, 460.0),
]
const DEFENDER_SPAWNS := [
	Vector2(1140.0, 540.0),
	Vector2(1140.0, 600.0),
	Vector2(1140.0, 660.0),
]
const PAPA_SPAWN := Vector2(960.0, 310.0)
const BEAST_SPAWN := Vector2(1080.0, 350.0)
const POT_ZONE := Rect2(944.0, 72.0, 112.0, 96.0)
const CAPTURE_ZONE := Rect2(856.0, 240.0, 208.0, 152.0)
const ESCAPE_ZONE := Rect2(32.0, 280.0, 320.0, 240.0)
const ROUTES := [
	Rect2(280.0, 280.0, 360.0, 160.0),
	Rect2(640.0, 260.0, 320.0, 160.0),
	Rect2(920.0, 120.0, 160.0, 200.0),
	Rect2(960.0, 400.0, 240.0, 240.0),
]
const TORRE_WALLS := [
	Rect2(880.0, 16.0, 288.0, 12.0),
	Rect2(880.0, 16.0, 12.0, 224.0),
	Rect2(1156.0, 16.0, 12.0, 224.0),
	Rect2(880.0, 228.0, 30.0, 12.0),
	Rect2(930.0, 228.0, 238.0, 12.0),
]

var _beast_gate_open := false
var _zones: Dictionary = {}

func _ready() -> void:
	_create_boundaries()
	_create_spawn_markers()
	_create_zones()
	queue_redraw()

func get_spawn_points() -> Dictionary:
	return {
		"attackers": ATTACKER_SPAWNS.duplicate(),
		"defenders": DEFENDER_SPAWNS.duplicate(),
		"papa": PAPA_SPAWN,
		"beast": BEAST_SPAWN,
	}

func get_map_bounds() -> Rect2:
	return MAP_BOUNDS

func get_route_rects() -> Array[Rect2]:
	return ROUTES.duplicate()

func is_position_inside_map(position: Vector2) -> bool:
	return MAP_BOUNDS.has_point(position)

func is_position_in_pot(position: Vector2) -> bool:
	return POT_ZONE.has_point(position)

func is_position_in_capture_zone(position: Vector2) -> bool:
	return CAPTURE_ZONE.has_point(position)

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
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.position.y, MAP_BOUNDS.size.x, 8.0),
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.end.y - 8.0, MAP_BOUNDS.size.x, 8.0),
		Rect2(MAP_BOUNDS.position.x, MAP_BOUNDS.position.y, 8.0, MAP_BOUNDS.size.y),
		Rect2(MAP_BOUNDS.end.x - 8.0, MAP_BOUNDS.position.y, 8.0, MAP_BOUNDS.size.y),
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

	for index in TORRE_WALLS.size():
		var torre_body := StaticBody2D.new()
		torre_body.name = "TorreWall%d" % index
		var torre_shape := CollisionShape2D.new()
		var torre_rectangle := RectangleShape2D.new()
		torre_rectangle.size = TORRE_WALLS[index].size
		torre_shape.shape = torre_rectangle
		torre_shape.position = TORRE_WALLS[index].get_center()
		torre_body.add_child(torre_shape)
		add_child(torre_body)

	var gate := StaticBody2D.new()
	gate.name = "BeastGate"
	var gate_shape := CollisionShape2D.new()
	gate_shape.name = "CollisionShape2D"
	var gate_rectangle := RectangleShape2D.new()
	gate_rectangle.size = Vector2(20.0, 80.0)
	gate_shape.shape = gate_rectangle
	gate_shape.position = Vector2(920.0, 220.0)
	gate.add_child(gate_shape)
	add_child(gate)

func _create_spawn_markers() -> void:
	var spawn_groups := {
		"AttackerSpawns": ATTACKER_SPAWNS,
		"DefenderSpawns": DEFENDER_SPAWNS,
	}
	for group_name in spawn_groups:
		var group := Node2D.new()
		group.name = group_name
		add_child(group)
		var points: Array = spawn_groups[group_name]
		for index in points.size():
			var marker := Marker2D.new()
			marker.name = "%s%d" % [group_name.trim_suffix("s"), index + 1]
			marker.position = points[index]
			group.add_child(marker)

	var special_spawns := Node2D.new()
	special_spawns.name = "SpecialSpawns"
	add_child(special_spawns)
	for spawn_data in [
		{"name": "PapaSpawn", "position": PAPA_SPAWN},
		{"name": "BeastSpawn", "position": BEAST_SPAWN},
	]:
		var marker := Marker2D.new()
		marker.name = spawn_data["name"]
		marker.position = spawn_data["position"]
		special_spawns.add_child(marker)

func _create_zones() -> void:
	_create_zone("CaptureZone", CAPTURE_ZONE)
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
	draw_rect(CAPTURE_ZONE, Color("#813f58", 0.25), true)
	draw_rect(POT_ZONE, Color("#8e5e38", 0.22), true)
	draw_rect(ESCAPE_ZONE, Color("#2a8c76", 0.22), true)
	draw_line(Vector2(920.0, 180.0), Vector2(920.0, 260.0), Color("#f0c674"), 6.0)
