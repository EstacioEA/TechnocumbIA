extends SceneTree

const MAIN_MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var main_menu := MAIN_MENU_SCENE.instantiate() as Control
	if main_menu == null:
		_fail("main menu did not instantiate")
		_finish()
		return
	root.add_child(main_menu)
	await process_frame

	main_menu.call("_open_lobby")
	await process_frame
	var lobby := main_menu.get_node_or_null("Lobby")
	if lobby == null:
		_fail("F5 flow did not create the lobby")
		_finish()
		return

	lobby.call("_on_lobby_start")
	await process_frame
	var game_session := root.get_node_or_null("PapoiGameSession")
	if game_session == null:
		_fail("lobby did not create the runtime game session")
	if main_menu.visible:
		_fail("main menu must be hidden when the runtime game starts")
	if main_menu.get_node_or_null("Background") != null and main_menu.get_node("Background").is_visible_in_tree():
		_fail("main menu background must not cover the gameplay map")
	if game_session != null:
		var map := game_session.get_node_or_null("Map")
		var background := map.get_node_or_null("Visuals/MapBackground") if map != null else null
		if background == null or not background.visible:
			_fail("runtime game map background must remain visible after F5 start")

	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("F5_GAME_START_VISIBILITY_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("F5_GAME_START_VISIBILITY_TEST: %s" % failure)
	quit(1)
