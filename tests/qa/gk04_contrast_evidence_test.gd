extends SceneTree

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	var hud := HUD_SCENE.instantiate() as PapoiHUD
	if map == null or player == null or hud == null:
		_fail("GK04 preview dependencies did not instantiate")
		_finish()
		return
	root.add_child(map)
	root.add_child(player)
	hud.layer = 30
	root.add_child(hud)
	await process_frame

	_assert_map_layers(map)
	_assert_overlay_layers(player, hud)
	_assert_hud_build(hud)
	_finish()

func _assert_map_layers(map: PapoiMap) -> void:
	var map_visuals := map.get_node_or_null("Visuals") as Node2D
	var base_visuals := map.get_node_or_null("BaseSpawnVisuals") as Node2D
	var pot_visuals := map.get_node_or_null("PotBarrierVisuals") as Node2D
	if map_visuals == null or map_visuals.z_index >= 0:
		_fail("map background must remain behind overlays")
	if base_visuals == null or base_visuals.z_index <= 0:
		_fail("base/spawn overlay must remain visible above the map")
	if pot_visuals == null or pot_visuals.z_index <= base_visuals.z_index:
		_fail("pot/barrier overlay must remain above base/spawn markers")

func _assert_overlay_layers(player: CharacterBody2D, hud: PapoiHUD) -> void:
	var overlay := player.get_node_or_null("VisionOverlay") as CanvasLayer
	if overlay == null or overlay.layer != 20:
		_fail("local vision overlay must use layer 20")
	if hud.layer <= overlay.layer:
		_fail("HUD must remain above the active vision overlay")
	var rect := overlay.get_node_or_null("OverlayRect") as ColorRect
	if rect == null or not rect.material is ShaderMaterial:
		_fail("vision overlay must use its shader material")

func _assert_hud_build(hud: PapoiHUD) -> void:
	if hud.get_child_count() == 0:
		_fail("HUD root was not built")

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GK04_CONTRAST_EVIDENCE_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GK04_CONTRAST_EVIDENCE_TEST: %s" % failure)
	quit(1)
