extends SceneTree

const GameScene = preload("res://scenes/game/papoi_game.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var escape_session: Variant = await _new_session()
	if escape_session == null:
		_report_and_quit()
		return
	var game_state: Node = escape_session.get_game_state()
	game_state._process(4.0)
	_check(game_state.get_snapshot().phase == GameEnums.GamePhase.ACTIVE, "lobby inicia countdown y entra en ACTIVE")
	var attacker_id := _first_player_with_side(game_state.get_snapshot(), "attacker")
	var map: Node2D = escape_session.get_node("Map")
	var attacker: Node2D = escape_session.get_player_node(attacker_id)
	attacker.global_position = map.get_spawn_points()["papa"]
	_check(escape_session.request_host_action(attacker_id, &"interact"), "host integra captura de Papa")
	attacker.global_position = map.to_global(map.POT_ROOM_CENTER)
	_check(escape_session.request_host_action(attacker_id, &"interact"), "host integra inicio de cocción en olla")
	_check(game_state.get_snapshot().phase == GameEnums.GamePhase.POT_COOKING, "GameState entra en POT_COOKING junto al módulo K03")
	escape_session._process(30.1)
	game_state._process(30.1)
	_check(game_state.get_snapshot().phase == GameEnums.GamePhase.ESCAPE, "cocción completa habilita escape en GameState")
	attacker.global_position = map.ESCAPE_ZONE.get_center()
	_check(escape_session.request_host_action(attacker_id, &"interact"), "escape en base atacante resuelve la ronda")
	var final_snapshot: Dictionary = game_state.get_snapshot()
	_check(final_snapshot.phase == GameEnums.GamePhase.ROUND_RESULT, "escape integrado llega a ROUND_RESULT")
	_check(int(final_snapshot.scores.get("TEAM_A", 0)) + int(final_snapshot.scores.get("TEAM_B", 0)) == 1, "GameState adjudica un único punto")
	_check(escape_session.get_node("HUD").result_panel.visible, "el HUD recibe y muestra el resultado autoritativo")
	escape_session.queue_free()
	await process_frame

	var rescue_session: Variant = await _new_session(true)
	if rescue_session == null:
		_report_and_quit()
		return
	game_state = rescue_session.get_game_state()
	game_state._process(4.0)
	var rescue_attacker_id := _first_player_with_side(game_state.get_snapshot(), "attacker")
	map = rescue_session.get_node("Map")
	attacker = rescue_session.get_player_node(rescue_attacker_id)
	attacker.global_position = map.get_spawn_points()["papa"]
	_check(rescue_session.request_host_action(rescue_attacker_id, &"interact"), "segunda ronda de prueba captura Papa")
	attacker.global_position = map.to_global(map.POT_ROOM_CENTER)
	_check(rescue_session.request_host_action(rescue_attacker_id, &"interact"), "segunda ronda de prueba inicia cocción")
	var beast_id := int(rescue_session._beast_state.beast_id)
	rescue_session.get_player_node(beast_id).global_position = map.to_global(map.POT_ROOM_CENTER)
	rescue_session._beast_state.appeared = true
	_check(rescue_session.request_host_action(beast_id, &"rescue"), "Bestia rescata mediante K03 y cancela cocción en GameState")
	_check(game_state.get_snapshot().phase == GameEnums.GamePhase.ACTIVE, "rescate vuelve de POT_COOKING a ACTIVE")
	_check(game_state.get_snapshot().papa_state == GameEnums.PapaState.FREE, "rescate libera a Papa en el snapshot autoritativo")
	rescue_session.queue_free()
	await process_frame

	if _failures.is_empty():
		print("GAME_INTEGRATION_TEST: PASS")
		quit(0)
		return
	_report_and_quit()


func _new_session(require_beast: bool = false) -> Variant:
	for seed_value in range(1, 100):
		var session := GameScene.instantiate()
		root.add_child(session)
		await process_frame
		session.get_game_state()._rng.seed = seed_value
		var roster: Array[Dictionary] = []
		for peer_id in range(1, 7):
			roster.append({"peer_id": peer_id, "ready": true})
		if not session.start_from_lobby_roster(roster):
			_check(false, "sesión de prueba configura el lobby autoritativo")
			session.queue_free()
			await process_frame
			return null
		if not require_beast or _first_player_with_role(session.get_game_state().get_snapshot(), GameEnums.DefenderRole.BESTIA) > 0:
			return session
		session.queue_free()
		await process_frame
	_check(false, "semilla de prueba asigna una Bestia para validar rescate integrado")
	return null


func _first_player_with_side(snapshot: Dictionary, side: String) -> int:
	for player: Dictionary in snapshot.get("players", []):
		if player.get("side", "") == side:
			return int(player.peer_id)
	_check(false, "hay jugador en el lado %s" % side)
	return -1


func _first_player_with_role(snapshot: Dictionary, role: int) -> int:
	for player: Dictionary in snapshot.get("players", []):
		if int(player.get("role", -1)) == role:
			return int(player.peer_id)
	return -1


func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures.append("FAIL: " + description)


func _report_and_quit() -> void:
	for failure in _failures:
		push_error(failure)
	quit(1)
