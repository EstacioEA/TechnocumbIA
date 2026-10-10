extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	if map == null or player == null:
		_fail("V03 scenes did not instantiate")
		_finish()
		return

	root.add_child(map)
	root.add_child(player)
	await process_frame
	await physics_frame

	player.set_local_control(false)
	await _assert_boundary_blocks(map, player)
	await _assert_gate_blocks(map, player)
	_finish()

func _assert_boundary_blocks(map: PapoiMap, player: CharacterBody2D) -> void:
	player.global_position = Vector2(100.0, 384.0)
	player.apply_authoritative_velocity(Vector2(-1000.0, 0.0))
	await physics_frame
	if player.global_position.x < map.get_map_bounds().position.x + 18.0:
		_fail("player crossed the west map boundary")

func _assert_gate_blocks(map: PapoiMap, player: CharacterBody2D) -> void:
	player.global_position = Vector2(640.0, 384.0)
	player.apply_authoritative_velocity(Vector2(1000.0, 0.0))
	await physics_frame
	if player.global_position.x > 670.0:
		_fail("player crossed the closed Beast gate")
	if map.is_beast_gate_open():
		_fail("Beast gate must start closed")

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("V03_PLAYER_COLLISION_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("V03_PLAYER_COLLISION_TEST: %s" % failure)
	quit(1)
