extends SceneTree

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")
const MAP_TEXTURE := preload("res://assets/maps/Mapa Base.jpeg")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game := GAME_SCENE.instantiate()
	if game == null:
		_fail("integrated game scene did not instantiate")
		_finish()
		return
	root.add_child(game)
	await process_frame

	var map := game.get_node_or_null("Map") as Node2D
	var hud := game.get_node_or_null("HUD") as CanvasLayer
	var visuals := map.get_node_or_null("Visuals") as Node2D if map != null else null
	var background := visuals.get_node_or_null("MapBackground") as Sprite2D if visuals != null else null
	if map == null:
		_fail("integrated game scene must contain the gameplay map")
	if hud == null:
		_fail("integrated game scene must contain the gameplay HUD")
	if visuals == null:
		_fail("integrated game scene must contain map visuals")
	if background == null:
		_fail("integrated game scene must contain the map background sprite")
	elif background.texture != MAP_TEXTURE or not background.visible:
		_fail("integrated game scene must display the reference map")
	if map != null and map.get_node_or_null("EscapeExitIndicator") == null:
		_fail("integrated map must contain the escape indicator")
	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("INTEGRATED_GAME_VISUAL_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("INTEGRATED_GAME_VISUAL_TEST: %s" % failure)
	quit(1)
