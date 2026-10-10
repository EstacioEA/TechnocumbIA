extends SceneTree

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")
const MAP_TEXTURE := preload("res://assets/maps/Mapa Base.jpeg")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game := GAME_SCENE.instantiate() as PapoiGameSession
	if game == null:
		_fail("game scene did not instantiate as PapoiGameSession")
		_finish()
		return
	root.add_child(game)
	game.enable_local_preview_mode()
	await process_frame

	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	if not game.start_from_lobby_roster(roster):
		_fail("runtime preview could not start with six players")
		_finish()
		return
	await process_frame

	var map := game.get_node("Map") as PapoiMap
	var visuals := map.get_node("Visuals") as Node2D
	var background := visuals.get_node("MapBackground") as Sprite2D
	if background.texture != MAP_TEXTURE or not background.visible:
		_fail("runtime map background is not visible after six players are created")
	if visuals.z_index >= 0:
		_fail("runtime map visual layer is not behind gameplay overlays")
	if background.get_global_transform().origin != Vector2(640.0, 360.0):
		_fail("runtime map background moved when players were created")
	if game._player_nodes.size() != 6:
		_fail("runtime preview did not create six player nodes")
	for peer_id: Variant in game._player_nodes:
		var player := game._player_nodes[peer_id] as CharacterBody2D
		var camera := player.get_node("LocalCamera") as Camera2D
		if camera == null:
			_fail("runtime player is missing its camera")
			continue
		var overlay := player.get_node("VisionOverlay") as CanvasLayer
		if overlay == null:
			_fail("runtime player is missing its vision overlay")

	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("RUNTIME_MAP_VISIBILITY_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("RUNTIME_MAP_VISIBILITY_TEST: %s" % failure)
	quit(1)
