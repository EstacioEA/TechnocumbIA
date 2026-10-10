class_name PapoiMap
extends Node2D

signal zone_entered(zone_name: String, body: Node2D)
signal zone_exited(zone_name: String, body: Node2D)

const MAP_BOUNDS := Rect2(0.0, 0.0, 1280.0, 720.0)
const ATTACKER_BASE := Vector2(190.0, 400.0)
const DEFENDER_BASE := Vector2(1140.0, 600.0)
const POT_ROOM_CENTER := Vector2(1000.0, 112.0)
const TOWER_KEY_SPAWN := Vector2(620.0, 330.0)
const BEAST_GATE_POSITION := Vector2(920.0, 220.0)
const BEAST_GATE_ACCESS_POSITION := Vector2(920.0, 270.0)
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
	Rect2(208.0, 280.0, 432.0, 160.0),
	Rect2(640.0, 260.0, 320.0, 160.0),
	Rect2(920.0, 120.0, 160.0, 200.0),
	Rect2(730.0, 398.0, 470.0, 240.0),
]
const PLAYABLE_CORRIDORS := [
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
const PLAYABLE_BLOCKERS := [
	Rect2(300.0, 310.0, 78.0, 56.0),
	Rect2(300.0, 410.0, 78.0, 72.0),
	Rect2(520.0, 294.0, 42.0, 62.0),
	Rect2(614.0, 286.0, 52.0, 74.0),
	Rect2(688.0, 316.0, 54.0, 44.0),
	Rect2(800.0, 306.0, 70.0, 56.0),
	Rect2(900.0, 306.0, 58.0, 54.0),
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
var _show_debug_overlay := false

func _ready() -> void:
	_create_boundaries()
	_create_spawn_markers()
	_create_zones()
	set_debug_overlay_visible(false)
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

func is_position_in_playable_route(position: Vector2) -> bool:
	for blocker in PLAYABLE_BLOCKERS:
		if blocker.has_point(position):
			return false
	for corridor in PLAYABLE_CORRIDORS:
		if corridor.has_point(position):
			return true
	return false

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
	apply_beast_gate_state(open)
	return true

func apply_beast_gate_state(open: bool) -> void:
	_beast_gate_open = open
	var gate := get_node_or_null("BeastGate/CollisionShape2D") as CollisionShape2D
	if gate:
		gate.disabled = open
	queue_redraw()

func is_beast_gate_open() -> bool:
	return _beast_gate_open

func get_beast_gate_position() -> Vector2:
	return to_global(BEAST_GATE_POSITION)

func get_beast_gate_access_position() -> Vector2:
	return to_global(BEAST_GATE_ACCESS_POSITION)

func set_debug_overlay_visible(enabled: bool) -> void:
	_show_debug_overlay = enabled
	var map_visuals := get_node_or_null("Visuals") as Node2D
	if map_visuals and map_visuals.has_method("set_route_debug_visible"):
		map_visuals.call("set_route_debug_visible", enabled)
	var base_visuals := get_node_or_null("BaseSpawnVisuals") as Node2D
	var pot_visuals := get_node_or_null("PotBarrierVisuals") as Node2D
	if base_visuals:
		base_visuals.visible = enabled
	if pot_visuals:
		pot_visuals.visible = enabled
	queue_redraw()

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
	gate_shape.position = BEAST_GATE_POSITION
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
	if not _show_debug_overlay:
		return
	draw_rect(CAPTURE_ZONE, Color("#813f58", 0.25), true)
	draw_rect(POT_ZONE, Color("#8e5e38", 0.22), true)
	draw_rect(ESCAPE_ZONE, Color("#2a8c76", 0.22), true)
	draw_line(Vector2(920.0, 180.0), Vector2(920.0, 260.0), Color("#f0c674"), 6.0)
	for corridor in PLAYABLE_CORRIDORS:
		draw_rect(corridor, Color("#f0c674", 0.12), false, 2.0)
	for blocker in PLAYABLE_BLOCKERS:
		draw_rect(blocker, Color("#d9534f", 0.20), true)
