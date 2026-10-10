extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		_fail("map scene did not instantiate as PapoiMap")
		_finish()
		return
	root.add_child(map)
	await process_frame

	_assert_map_structure(map)
	_assert_gate_access_zone(map)
	await physics_frame
	_assert_boundary_collision(map)
	_assert_gate_collision(map)
	_finish()

func _assert_map_structure(map: PapoiMap) -> void:
	var spawns := map.get_spawn_points()
	if spawns.get("attackers", []).size() != 3:
		_fail("expected three attacker spawn points")
	if spawns.get("defenders", []).size() != 3:
		_fail("expected three defender spawn points")
	if not spawns.has("papa") or not spawns.has("beast"):
		_fail("expected Papa and Beast spawn points")
	if map.get_node_or_null("AttackerSpawns/AttackerSpawn1") == null:
		_fail("attacker Marker2D nodes are missing")
	if map.get_node_or_null("DefenderSpawns/DefenderSpawn1") == null:
		_fail("defender Marker2D nodes are missing")
	if map.get_node_or_null("SpecialSpawns/PapaSpawn") == null:
		_fail("Papa spawn marker is missing")
	if map.get_node_or_null("SpecialSpawns/BeastSpawn") == null:
		_fail("Beast spawn marker is missing")
	if map.get_route_rects().size() != 4:
		_fail("expected four traversable route rectangles")

func _assert_boundary_collision(map: PapoiMap) -> void:
	var body := _create_probe(Vector2(80.0, 384.0))
	map.add_child(body)
	var collision := body.move_and_collide(Vector2(-100.0, 0.0))
	if collision == null:
		_fail("map boundary did not block probe movement")
	body.queue_free()

func _assert_gate_collision(map: PapoiMap) -> void:
	var body := _create_probe(Vector2(908.0, 200.0))
	map.add_child(body)
	var collision := body.move_and_collide(Vector2(100.0, 0.0))
	if collision == null:
		_fail("closed Beast gate did not block probe movement")
	if map.is_beast_gate_open():
		_fail("Beast gate must start closed")

	if not map.set_beast_gate_open(true, true):
		_fail("host could not open Beast gate for passage test")
		body.queue_free()
		return
	var open_collision := body.move_and_collide(Vector2(100.0, 0.0))
	if open_collision != null:
		_fail("open Beast gate still blocks passage")
	map.set_beast_gate_open(false, true)

	if not map.set_beast_gate_open(true, true):
		_fail("host could not reopen Beast gate for player-size passage test")
		return
	var player_shape := body.get_child(0).shape as CircleShape2D
	player_shape.radius = 18.0
	body.position = Vector2(911.0, 200.0)
	var player_size_collision := body.move_and_collide(Vector2(60.0, 0.0))
	if player_size_collision != null:
		_fail("open Beast gate does not fit the player collision radius")
	body.queue_free()
	map.set_beast_gate_open(false, true)

func _assert_gate_access_zone(map: PapoiMap) -> void:
	if not map.is_position_in_beast_gate_access(Vector2(1002.0, 180.0)):
		_fail("gate access zone does not include the upper approach corridor")
	if not map.is_position_in_beast_gate_access(Vector2(1082.0, 266.0)):
		_fail("gate access zone does not include the full upper approach corridor")
	if not map.is_position_in_beast_gate_access(Vector2(900.0, 300.0)):
		_fail("gate approach zone does not include the exterior corridor")

func _create_probe(position: Vector2, radius: float = 8.0) -> CharacterBody2D:
	var body := CharacterBody2D.new()
	body.position = position
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	body.add_child(collision)
	return body

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("K01_MAP_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("K01_MAP_TEST: %s" % failure)
	quit(1)
