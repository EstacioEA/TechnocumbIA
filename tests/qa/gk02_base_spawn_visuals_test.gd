extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const VISUALS_SCRIPT := preload("res://scenes/map/visuals/papoi_base_spawn_visuals.gd")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		_fail("map scene did not instantiate")
		_finish()
		return
	root.add_child(map)
	await process_frame
	var expected_spawns := map.get_spawn_points()
	var visuals := map.get_node_or_null("BaseSpawnVisuals") as Node2D
	if visuals == null:
		_fail("base/spawn visual layer is missing")
	else:
		if visuals.get_script() != VISUALS_SCRIPT:
			_fail("base/spawn visual layer has an unexpected script")
		if visuals.z_index <= 0:
			_fail("base/spawn markers must remain visible above the map floor")
	_assert_spawn_markers(map, expected_spawns)
	map.queue_free()
	await process_frame
	_finish()

func _assert_spawn_markers(map: PapoiMap, expected_spawns: Dictionary) -> void:
	for group_name in ["AttackerSpawns", "DefenderSpawns"]:
		var group := map.get_node_or_null(group_name) as Node2D
		if group == null or group.get_child_count() != 3:
			_fail("%s must contain three logical markers" % group_name)
	var special := map.get_node_or_null("SpecialSpawns") as Node2D
	if special == null or special.get_child_count() != 2:
		_fail("special spawn group must contain Papa and Beast")
	if map.get_spawn_points() != expected_spawns:
		_fail("visual layer changed logical spawn data")

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GK02_BASE_SPAWN_VISUALS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GK02_BASE_SPAWN_VISUALS_TEST: %s" % failure)
	quit(1)
