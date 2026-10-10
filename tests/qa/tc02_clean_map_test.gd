extends Node

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")

var _failures: Array[String] = []

func _ready() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		_fail("map scene did not instantiate")
		_finish()
		return
	add_child(map)
	await get_tree().process_frame

	var base_visuals := map.get_node_or_null("BaseSpawnVisuals") as Node2D
	var pot_visuals := map.get_node_or_null("PotBarrierVisuals") as Node2D
	if base_visuals == null or base_visuals.visible:
		_fail("base and spawn debug overlays must be hidden in gameplay")
	if pot_visuals == null or pot_visuals.visible:
		_fail("pot and barrier debug overlays must be hidden in gameplay")

	map.set_debug_overlay_visible(true)
	if not base_visuals.visible or not pot_visuals.visible:
		_fail("debug overlays must be activatable by previews")

	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("TC02_CLEAN_MAP_TEST: PASS")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("TC02_CLEAN_MAP_TEST: %s" % failure)
	get_tree().quit(1)
