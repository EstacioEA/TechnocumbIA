extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const VISUALS_SCENE := preload("res://scenes/map/visuals/papoi_map_visuals.tscn")
const VISUALS_SCRIPT := preload("res://scenes/map/visuals/papoi_map_visuals.gd")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		_fail("map scene did not instantiate")
		_finish()
		return
	root.add_child(map)
	await process_frame
	var visuals := map.get_node_or_null("Visuals") as Node2D
	if visuals == null:
		_fail("map visual layer is not instanced under PapoiMap")
	else:
		_assert_visual_contract(visuals)
	var standalone := VISUALS_SCENE.instantiate() as Node2D
	if standalone == null:
		_fail("visual scene did not instantiate")
	else:
		root.add_child(standalone)
		await process_frame
		standalone.queue_free()
	map.queue_free()
	await process_frame
	_finish()

func _assert_visual_contract(visuals: Node2D) -> void:
	if visuals.get_script() != VISUALS_SCRIPT:
		_fail("map visual layer has an unexpected script")
	if visuals.z_index >= 0:
		_fail("visual layer must stay behind gameplay overlays")

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GK01_MAP_VISUALS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GK01_MAP_VISUALS_TEST: %s" % failure)
	quit(1)
