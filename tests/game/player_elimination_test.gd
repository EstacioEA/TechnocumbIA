extends SceneTree

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var session := GAME_SCENE.instantiate()
	root.add_child(session)
	await process_frame
	session.enable_local_preview_mode()

	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	if not session.start_from_lobby_roster(roster):
		_fail("could not start authoritative match")
		_finish(session)
		return
	session.get_game_state()._process(4.0)
	await process_frame

	var snapshot: Dictionary = session.get_game_state().get_snapshot()
	var attacker_ids: Array[int] = []
	var defender_id := -1
	for player: Dictionary in snapshot.players:
		if player.get("side", "") == "attacker":
			attacker_ids.append(int(player.peer_id))
		elif int(player.get("role", -1)) in [
			GameEnums.DefenderRole.TROLAZZO,
			GameEnums.DefenderRole.BESTIA,
		]:
			defender_id = int(player.peer_id)
	if attacker_ids.size() != 3 or defender_id <= 0:
		_fail("expected three attackers and a defender")
		_finish(session)
		return

	var defender := session.get_player_node(defender_id) as CharacterBody2D
	if defender == null:
		_fail("defender actor is missing")
		_finish(session)
		return

	for attacker_id: int in attacker_ids:
		var attacker := session.get_player_node(attacker_id) as CharacterBody2D
		if attacker == null:
			_fail("attacker actor is missing: %d" % attacker_id)
			continue
		defender.global_position = attacker.global_position
		for hit in 3:
			if not session._lives_state.request_hit_without_papa(attacker_id, false):
				_fail("authoritative lives state rejected attacker %d" % attacker_id)
				break
			if not session.get_game_state().register_attacker_hit(attacker_id, false):
				_fail("authoritative game state rejected attacker %d" % attacker_id)
				break
			session._publish_snapshot()
			if hit < 2:
				session._process(3.0)
				session._publish_snapshot()
		if attacker.visible:
			_fail("attacker %d remained visible after losing all lives" % attacker_id)
		if attacker.get("local_control_enabled"):
			_fail("eliminated attacker retained local control")

	var final_snapshot: Dictionary = session.get_game_state().get_snapshot()
	_check(final_snapshot.phase == GameEnums.GamePhase.ROUND_RESULT, "all eliminated attackers resolve the round")
	_check(final_snapshot.round_winner == 1 - int(final_snapshot.attacking_team), "defenders win elimination")
	_finish(session)

func _check(condition: bool, message: String) -> void:
	if not condition:
		_fail(message)

func _fail(message: String) -> void:
	_failures.append(message)

func _finish(session: Node) -> void:
	session.queue_free()
	if _failures.is_empty():
		print("PLAYER_ELIMINATION_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("PLAYER_ELIMINATION_TEST: %s" % failure)
	quit(1)
