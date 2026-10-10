extends SceneTree

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game := GAME_SCENE.instantiate() as PapoiGameSession
	if game == null:
		_fail("game scene did not instantiate")
		_finish()
		return
	root.add_child(game)
	game.enable_local_preview_mode()
	await process_frame

	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	if not game.start_from_lobby_roster(roster):
		_fail("runtime game did not start with six players")
		_finish()
		return
	await create_timer(3.2).timeout

	var key_state: Variant = game.get("_tower_key_state")
	var marker := game.get_node_or_null("Map/TowerKeyToken") as Sprite2D
	var map := game.get_node("Map") as PapoiMap
	if key_state == null:
		_fail("runtime game did not create TowerKeyState")
		_finish()
		return
	var key_snapshot: Dictionary = key_state.get_snapshot()
	_check(bool(key_snapshot.get("key_visible", false)), "initial tower key must be visible")
	_check(key_snapshot.get("key_position") == map.to_global(map.TOWER_KEY_SPAWN), "key must spawn at the configured map point")
	if marker == null or not marker.visible:
		_fail("runtime game must render the initial tower key marker")

	var attacker_id := -1
	for player: Dictionary in game.get_game_state().get_snapshot().players:
		if player.get("side", "") == "attacker":
			attacker_id = int(player.peer_id)
			break
	_check(attacker_id > 0, "runtime game must have an attacker to collect the key")
	if attacker_id > 0:
		var attacker := game.get_player_node(attacker_id)
		attacker.global_position = map.to_global(map.TOWER_KEY_SPAWN)
		_check(game.request_host_action(attacker_id, &"interact"), "attacker collects the tower key")
		_check(not bool(key_state.get_snapshot().get("key_visible", true)), "collected key is hidden from the map")
		_check(int(key_state.get_snapshot().get("key_holder_id", -1)) == attacker_id, "key holder is replicated in runtime state")
		attacker.global_position = map.to_global(Vector2(920.0, 270.0))
		_check(game.request_host_action(attacker_id, &"interact"), "key holder opens the tower gate")
		_check(map.is_beast_gate_open(), "tower gate opens after key interaction")

	_finish()

func _check(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("TOWER_KEY_RUNTIME_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("TOWER_KEY_RUNTIME_TEST: %s" % failure)
	quit(1)
