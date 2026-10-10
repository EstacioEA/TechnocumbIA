extends SceneTree

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var session: PapoiGameSession = null
	var snapshot: Dictionary = {}
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	for seed_value in range(1, 100):
		session = GAME_SCENE.instantiate() as PapoiGameSession
		if session == null:
			_fail("game scene did not instantiate as PapoiGameSession")
			_finish()
			return
		root.add_child(session)
		session.enable_local_preview_mode()
		await process_frame
		session.get_game_state()._rng.seed = seed_value
		if session.start_from_lobby_roster(roster):
			session.get_game_state()._process(4.0)
			await process_frame
			snapshot = session.get_game_state().get_snapshot()
			if _find_role(snapshot, GameEnums.DefenderRole.BESTIA) > 0:
				break
		session.queue_free()
		await process_frame

	if session == null or not is_instance_valid(session):
		_fail("runtime roster could not create a test session")
		_finish()
		return

	var beast_state: Variant = session.get("_beast_state")
	var beast_id := int(beast_state.beast_id) if beast_state != null else -1
	var attacker_id := _find_attacker(snapshot)
	if beast_id < 0 or attacker_id < 0:
		_fail("runtime roster did not create Bestia and attacker")
		_finish()
		return

	var beast := session.get_player_node(beast_id)
	var attacker := session.get_player_node(attacker_id)
	if beast == null or attacker == null:
		_fail("runtime player nodes are missing")
		_finish()
		return
	beast.global_position = Vector2(500.0, 300.0)
	attacker.global_position = Vector2(520.0, 300.0)

	session._process(30.0)
	var lives_state: Variant = session.get("_lives_state")
	_assert_true(bool(beast_state.appeared), "Bestia appears before using Q")

	var initial_lives := int(lives_state.get_player_state(attacker_id).get("lives", -1))
	_assert_true(session.request_host_action(beast_id, &"beast_attack"), "Q attack succeeds near attacker")
	var after_hit_lives := int(lives_state.get_player_state(attacker_id).get("lives", -1))
	_assert_equal(after_hit_lives, initial_lives - 1, "Q attack removes one attacker life")
	_assert_false(session.request_host_action(beast_id, &"beast_attack"), "Q attack is blocked during cooldown")

	session._process(5.0)
	_assert_true(session.request_host_action(beast_id, &"beast_attack"), "Q attack succeeds after five seconds")

	_finish()

func _find_role(snapshot: Dictionary, role: int) -> int:
	for player: Dictionary in snapshot.get("players", []):
		if int(player.get("role", -1)) == role:
			return int(player.get("peer_id", -1))
	return -1

func _find_attacker(snapshot: Dictionary) -> int:
	for player: Dictionary in snapshot.get("players", []):
		if player.get("side", "") == "attacker":
			return int(player.get("peer_id", -1))
	return -1

func _assert_true(value: bool, label: String) -> void:
	if not value:
		_fail(label)

func _assert_false(value: bool, label: String) -> void:
	_assert_true(not value, label)

func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		_fail("%s (actual=%s expected=%s)" % [label, actual, expected])

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("beast_attack_runtime_test: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("beast_attack_runtime_test: %s" % failure)
	quit(1)
