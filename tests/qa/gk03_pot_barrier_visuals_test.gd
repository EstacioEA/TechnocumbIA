extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const VISUALS_SCRIPT := preload("res://scenes/map/visuals/papoi_pot_barrier_visuals.gd")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		_fail("map scene did not instantiate")
		_finish()
		return
	root.add_child(map)
	await process_frame
	var visuals := map.get_node_or_null("PotBarrierVisuals") as Node2D
	if visuals == null:
		_fail("pot/barrier visual layer is missing")
	else:
		if visuals.get_script() != VISUALS_SCRIPT:
			_fail("pot/barrier visual layer has an unexpected script")
		if visuals.z_index <= 0:
			_fail("pot/barrier visuals must remain above the map floor")
	if map.is_beast_gate_open():
		_fail("Beast gate must start closed")
	if not map.set_beast_gate_open(true, false):
		if map.is_beast_gate_open():
			_fail("unauthorized gate transition changed logical state")
	else:
		_fail("unauthorized gate transition was accepted")
	if not map.set_beast_gate_open(true, true):
		_fail("host-authorized gate transition was rejected")
	if not map.is_beast_gate_open():
		_fail("authorized gate transition did not change logical state")
	if not map.set_beast_gate_open(false, true):
		_fail("host-authorized gate close was rejected")
	if map.is_beast_gate_open():
		_fail("authorized gate close did not change logical state")
	map.queue_free()
	await process_frame
	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GK03_POT_BARRIER_VISUALS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GK03_POT_BARRIER_VISUALS_TEST: %s" % failure)
	quit(1)
