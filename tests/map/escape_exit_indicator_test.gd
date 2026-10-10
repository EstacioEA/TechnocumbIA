extends SceneTree

const INDICATOR_SCENE := preload("res://scenes/map/escape_exit_indicator.tscn")
const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")

var _failures: Array[String] = []
var _signal_count := 0

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	var indicator := INDICATOR_SCENE.instantiate() as Node2D
	if map == null or indicator == null:
		_fail("map or exit indicator did not instantiate")
		_finish()
		return
	root.add_child(map)
	root.add_child(indicator)
	await process_frame

	var original_escape_zone: Rect2 = map.ESCAPE_ZONE
	var original_pot_zone: Rect2 = map.POT_ZONE
	_assert_closed_state(indicator)
	_assert_no_collision_nodes(indicator)
	_assert_map_geometry(map, original_escape_zone, original_pot_zone)

	_signal_count = 0
	indicator.escape_availability_changed.connect(_on_escape_availability_changed)
	indicator.set_escape_available(false)
	if _signal_count != 0:
		_fail("idempotent closed update emitted a signal")
	indicator.set_escape_available(true)
	if not indicator.is_escape_available():
		_fail("escape indicator did not activate")
	if indicator.get_node("StatusLabel").text != "SALIDA ACTIVA":
		_fail("active state label is missing")
	if _signal_count != 1:
		_fail("active transition should emit exactly one signal")
	indicator.set_escape_available(true)
	if _signal_count != 1:
		_fail("idempotent active update emitted a signal")
	_assert_map_geometry(map, original_escape_zone, original_pot_zone)
	_finish()

func _assert_closed_state(indicator: Node2D) -> void:
	if indicator.is_escape_available():
		_fail("exit must start closed")
	if indicator.get_node("StatusLabel").text != "SALIDA CERRADA":
		_fail("closed state label is missing")

func _assert_no_collision_nodes(indicator: Node) -> void:
	for child in indicator.get_children():
		if child is CollisionObject2D or child is CollisionShape2D:
			_fail("exit indicator must not add collision nodes")

func _assert_map_geometry(map: PapoiMap, escape_zone: Rect2, pot_zone: Rect2) -> void:
	if map.ESCAPE_ZONE != escape_zone or map.POT_ZONE != pot_zone:
		_fail("indicator changed map zone geometry")
	if map.get_node_or_null("EscapeZone") == null or map.get_node_or_null("PotZone") == null:
		_fail("map zones disappeared")

func _fail(message: String) -> void:
	_failures.append(message)

func _on_escape_availability_changed(_enabled: bool) -> void:
	_signal_count += 1

func _finish() -> void:
	if _failures.is_empty():
		print("V06_ESCAPE_EXIT_INDICATOR_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("V06_ESCAPE_EXIT_INDICATOR_TEST: %s" % failure)
	quit(1)
