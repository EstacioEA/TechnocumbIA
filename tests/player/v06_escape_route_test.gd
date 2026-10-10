extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	if map == null or player == null:
		_fail("map or player did not instantiate")
		_finish()
		return
	root.add_child(map)
	map.add_child(player)
	await process_frame

	for action in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		if not InputMap.has_action(action):
			_fail("missing WASD action: %s" % action)

	var spawn: Vector2 = map.get_spawn_points()["attackers"][0]
	var pot_center := map.POT_ZONE.get_center()
	var escape_center := map.ESCAPE_ZONE.get_center()
	if not map.is_position_in_playable_route(spawn):
		_fail("attacker spawn is not connected to a playable corridor")
	if not map.is_position_in_playable_route(pot_center):
		_fail("pot center is not in a playable corridor")
	if not map.is_position_in_playable_route(escape_center):
		_fail("escape center is not in a playable corridor")
	if not map.is_position_in_pot(pot_center):
		_fail("route target is outside POT_ZONE")
	if not map.is_position_in_escape(escape_center):
		_fail("route target is outside ESCAPE_ZONE")

	player.position = spawn
	var checkpoints := [
		Vector2(240.0, 400.0),
		Vector2(400.0, 335.0),
		Vector2(580.0, 240.0),
		Vector2(760.0, 320.0),
		Vector2(960.0, 200.0),
		pot_center,
		Vector2(760.0, 320.0),
		Vector2(580.0, 240.0),
		Vector2(400.0, 335.0),
		escape_center,
	]
	for checkpoint: Vector2 in checkpoints:
		if not map.is_position_in_playable_route(checkpoint):
			_fail("WASD route checkpoint is blocked: %s" % checkpoint)
	player.queue_free()
	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("V06_ESCAPE_ROUTE_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("V06_ESCAPE_ROUTE_TEST: %s" % failure)
	quit(1)
