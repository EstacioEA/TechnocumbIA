extends SceneTree

const FLOW_SCENE := preload("res://scenes/objectives/papoi_objective_flow.tscn")
const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _init() -> void:
	var map = MAP_SCENE.instantiate()
	var flow = FLOW_SCENE.instantiate()
	if map == null or flow == null:
		_fail("K02 scenes did not instantiate")
		_finish()
		return
	root.add_child(map)
	root.add_child(flow)
	await process_frame

	_assert_capture_zone(map)
	_assert_pot_validation(flow, map)
	_finish()

func _assert_capture_zone(map) -> void:
	if map.get_node_or_null("CaptureZone") == null:
		_fail("capture zone node is missing")
	if not map.is_position_in_capture_zone(Vector2(960.0, 316.0)):
		_fail("Summan capture approach position must be inside capture zone")

func _assert_pot_validation(flow, map) -> void:
	var papa_position := Vector2(1000.0, 120.0)
	if not map.is_position_in_pot(papa_position):
		_fail("pot center must be inside pot zone")
	if flow.detect_papa_in_pot(7, GameEnums.PapaState.FREE, true, true):
		_fail("free Papa must not be valid in pot")
	if flow.detect_papa_in_pot(7, GameEnums.PapaState.CAPTURED, false, true):
		_fail("captured Papa outside pot must not be valid")
	if not flow.detect_papa_in_pot(7, GameEnums.PapaState.CAPTURED, true, true):
		_fail("captured Papa inside pot must be valid")
	if flow.detect_papa_in_pot(7, GameEnums.PapaState.CAPTURED, true, false):
		_fail("unauthorized host transition must be rejected")
	if not flow.papa_in_pot:
		_fail("valid Papa detection must update flow state")

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("K02_POT_ZONE_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("K02_POT_ZONE_TEST: %s" % failure)
	quit(1)
