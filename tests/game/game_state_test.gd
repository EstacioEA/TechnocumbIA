extends SceneTree

const GameStateNode = preload("res://scripts/game/game_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")

var failures: Array[String] = []
var observed_round_results: Array[Dictionary] = []
var observed_match_results: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	if not _test_json_round_trip():
		quit(1)
		return
	if not _test_rejected_transitions_do_not_mutate():
		quit(1)
		return
	var game := GameStateNode.new()
	root.add_child(game)
	game.round_finished.connect(_record_round_result)
	game.match_finished.connect(_record_match_result)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	_check(game.configure_lobby(roster), "se configura un lobby con seis jugadores listos")
	_check(game.start_match(), "el host inicia la partida")
	_check(GameStateNode.MAX_ROUND_DURATION_SECONDS == 420.0, "el límite de ronda está parametrizado en siete minutos")
	game._process(4.0)
	var countdown_snapshot: Dictionary = game.get_snapshot()
	_check(countdown_snapshot.phase == GameEnums.GamePhase.ACTIVE, "COUNTDOWN transiciona a ACTIVE")
	_check(countdown_snapshot.round_time_remaining == GameStateNode.MAX_ROUND_DURATION_SECONDS, "ACTIVE inicia con el máximo de siete minutos")
	var first_attack: int = int(game.get_snapshot()["attacking_team"])
	_check(not game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS), "se rechaza escape antes de ESCAPE")
	var first_attack_score_key := MatchStateData.team_score_key(first_attack)
	_check(game.get_snapshot().scores[first_attack_score_key] == 0, "resultado inválido no altera marcador")
	_check(game.capture_papa(), "el host captura Papa")
	_check(game.begin_pot_cooking(), "el host inicia cocción")
	game._process(GameStateNode.POT_COOKING_DURATION_SECONDS + 1.0)
	_check(game.get_snapshot().phase == GameEnums.GamePhase.ESCAPE, "cocción completada habilita ESCAPE")
	_check(game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS), "escape válido resuelve la ronda")
	_check(game.get_snapshot().scores[first_attack_score_key] == 1, "ronda incrementa marcador una vez")
	_check(observed_round_results.size() == 1 and observed_round_results[0].winner == first_attack and observed_round_results[0].reason == GameEnums.RoundEndReason.ESCAPE_SUCCESS, "el resultado de escape se comunica una vez al host con ganador y razón")
	var score_after_escape: int = int(game.get_snapshot().scores[first_attack_score_key])
	_check(not game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS), "se rechaza resolver la misma ronda dos veces")
	_check(int(game.get_snapshot().scores[first_attack_score_key]) == score_after_escape and observed_round_results.size() == 1, "resolver dos veces no duplica puntos ni eventos")
	var round_result_snapshot: Dictionary = game.get_snapshot()
	_check(not game._set_phase(GameEnums.GamePhase.MATCH_RESULT), "se rechaza MATCH_RESULT antes de tres puntos")
	_check(game.get_snapshot() == round_result_snapshot, "MATCH_RESULT inválido no muta el estado")
	for expected_round in range(2, 5):
		_check(game.start_next_round(), "inicia la siguiente ronda")
		game._process(4.0)
		var snapshot: Dictionary = game.get_snapshot()
		_check(snapshot.round_number == expected_round, "número de ronda esperado")
		var expected_attack: int = 1 - first_attack if expected_round % 2 == 0 else first_attack
		_check(snapshot.attacking_team == expected_attack, "los lados alternan cada ronda")
		_check(_eliminate_attackers(game), "eliminación real de atacantes resuelve ronda")
		_check(game.get_snapshot().round_winner == 1 - snapshot.attacking_team, "la eliminación concede la ronda al equipo defensor")
	_check(game.get_snapshot().phase == GameEnums.GamePhase.MATCH_RESULT, "tres puntos finalizan la partida")
	_check(game.get_snapshot().match_winner == first_attack, "ganador de partida correcto")
	_check(observed_match_results.size() == 1 and observed_match_results[0].winner == first_attack, "el resultado de partida se comunica una vez al host")
	_check(not game.start_next_round(), "no inicia una ronda después de MATCH_RESULT")
	if not _test_timeout_transition():
		_report_failures()
		quit(1)
		return
	if not _test_elimination_transition_during_cooking():
		_report_failures()
		quit(1)
		return
	if not _test_disconnect_invalidates_without_score():
		_report_failures()
		quit(1)
		return
	if not _test_fifth_round_transition():
		_report_failures()
		quit(1)
		return
	if failures.is_empty():
		print("PASS: game state system")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _test_rejected_transitions_do_not_mutate() -> bool:
	var game := GameStateNode.new()
	root.add_child(game)
	game.round_finished.connect(_record_round_result)
	game.match_finished.connect(_record_match_result)
	var snapshot_before: Dictionary = game.get_snapshot()
	_check(not game._set_phase(GameEnums.GamePhase.ACTIVE), "se rechaza LOBBY -> ACTIVE")
	_check(game.get_snapshot() == snapshot_before, "transición inválida desde LOBBY no muta estado")
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	_check(game.configure_lobby(roster), "se configura lobby para validar transiciones inválidas")
	_check(game.start_match(), "se entra en COUNTDOWN para validar transiciones inválidas")
	snapshot_before = game.get_snapshot()
	_check(not game._set_phase(GameEnums.GamePhase.POT_COOKING), "se rechaza COUNTDOWN -> POT_COOKING")
	_check(not game.capture_papa(), "se rechaza captura de Papa durante COUNTDOWN")
	_check(game.get_snapshot() == snapshot_before, "transiciones inválidas desde COUNTDOWN no mutan estado")
	game._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
	snapshot_before = game.get_snapshot()
	_check(not game.begin_pot_cooking(), "se rechaza iniciar cocción sin capturar a Papa")
	_check(not game.resolve_round(int(game.get_snapshot().attacking_team), GameEnums.RoundEndReason.ESCAPE_SUCCESS), "se rechaza escape antes de ESCAPE")
	_check(not game.resolve_round(1 - int(game.get_snapshot().attacking_team), GameEnums.RoundEndReason.ATTACKERS_ELIMINATED), "se rechaza eliminación mientras queden vidas")
	_check(game.get_snapshot() == snapshot_before, "transiciones inválidas desde ACTIVE no mutan estado")
	game.queue_free()
	return failures.is_empty()


func _test_timeout_transition() -> bool:
	var game: Variant = _new_active_game()
	if game == null:
		return false
	observed_round_results.clear()
	game.round_finished.connect(_record_round_result)
	var defending_team: int = 1 - int(game.get_snapshot().attacking_team)
	game._process(GameStateNode.MAX_ROUND_DURATION_SECONDS + 1.0)
	var snapshot: Dictionary = game.get_snapshot()
	_check(snapshot.phase == GameEnums.GamePhase.ROUND_RESULT, "el tiempo agotado transiciona ACTIVE -> ROUND_RESULT")
	_check(snapshot.round_winner == defending_team, "el tiempo agotado asigna victoria al equipo defensor")
	_check(snapshot.round_time_remaining == 0.0, "el temporizador llega a cero sin exceder el máximo")
	_check(observed_round_results.size() == 1, "el timeout comunica el resultado al host una vez")
	_check(observed_round_results[0].winner == defending_team and observed_round_results[0].reason == GameEnums.RoundEndReason.TIME_EXPIRED, "el evento de timeout incluye ganador y razón")
	_check(snapshot.scores[MatchStateData.team_score_key(defending_team)] == 1, "timeout incrementa el marcador una sola vez")
	game.queue_free()
	return failures.is_empty()


func _test_elimination_transition_during_cooking() -> bool:
	var game: Variant = _new_active_game()
	if game == null:
		return false
	observed_round_results.clear()
	game.round_finished.connect(_record_round_result)
	var attacking_team: int = int(game.get_snapshot().attacking_team)
	var attacker_ids: Array[int] = []
	for player in game.get_snapshot().players:
		if player.side == "attacker":
			attacker_ids.append(int(player.peer_id))
	_check(attacker_ids.size() == 3, "asignación de atacantes disponible para el test de eliminación")
	_check(game.capture_papa(), "Papa se captura antes de probar eliminación durante cocción")
	_check(game.begin_pot_cooking(), "ACTIVE transiciona a POT_COOKING")
	for peer_id in attacker_ids:
		for hit_index in range(GameStateNode.STARTING_LIVES_PER_ATTACKER):
			game.register_attacker_hit(peer_id, false)
	var snapshot: Dictionary = game.get_snapshot()
	_check(snapshot.phase == GameEnums.GamePhase.ROUND_RESULT, "eliminación durante POT_COOKING transiciona a ROUND_RESULT")
	_check(snapshot.round_winner == 1 - attacking_team, "eliminación asigna victoria al equipo defensor")
	_check(observed_round_results.size() == 1, "eliminación comunica el resultado al host una vez")
	_check(observed_round_results[0].winner == 1 - attacking_team and observed_round_results[0].reason == GameEnums.RoundEndReason.ATTACKERS_ELIMINATED, "el evento de eliminación identifica ganador y razón")
	game.queue_free()
	return failures.is_empty()


func _test_disconnect_invalidates_without_score() -> bool:
	var game: Variant = _new_active_game()
	if game == null:
		return false
	observed_round_results.clear()
	observed_match_results.clear()
	game.round_finished.connect(_record_round_result)
	game.match_finished.connect(_record_match_result)
	var scores_before: Dictionary = game.get_snapshot().scores.duplicate(true)
	_check(not game.resolve_round(0, GameEnums.RoundEndReason.DISCONNECT), "una desconexión no acepta un equipo ganador inventado")
	_check(game.resolve_round(-1, GameEnums.RoundEndReason.DISCONNECT), "el host puede invalidar una partida por desconexión no recuperable")
	var snapshot: Dictionary = game.get_snapshot()
	_check(snapshot.phase == GameEnums.GamePhase.MATCH_RESULT, "la desconexión no recuperable cierra la partida")
	_check(snapshot.round_winner == -1 and snapshot.match_winner == -1, "la partida invalidada no inventa un ganador")
	_check(snapshot.round_end_reason == GameEnums.RoundEndReason.DISCONNECT, "el estado conserva la razón de invalidación")
	_check(snapshot.scores == scores_before, "la desconexión no adjudica puntos")
	_check(observed_round_results.size() == 1 and observed_round_results[0].winner == -1 and observed_round_results[0].reason == GameEnums.RoundEndReason.DISCONNECT, "round_result comunica al host la invalidación")
	_check(observed_match_results.size() == 1 and observed_match_results[0].winner == -1, "match_result comunica al host que no hay ganador")
	var final_snapshot: Dictionary = game.get_snapshot()
	_check(not game.resolve_round(-1, GameEnums.RoundEndReason.DISCONNECT), "se rechaza invalidar dos veces la misma partida")
	_check(game.get_snapshot() == final_snapshot, "repetir desconexión no altera el resultado final")
	game.queue_free()
	return failures.is_empty()


func _test_fifth_round_transition() -> bool:
	var game: Variant = _new_active_game()
	if game == null:
		return false
	for round_index in range(GameStateNode.BEST_OF_ROUNDS - 1):
		var attacking_team: int = int(game.get_snapshot().attacking_team)
		_check(game.capture_papa(), "la ronda activa permite capturar Papa")
		_check(game.begin_pot_cooking(), "la ronda avanza a POT_COOKING")
		game._process(GameStateNode.POT_COOKING_DURATION_SECONDS + 0.1)
		_check(game.get_snapshot().phase == GameEnums.GamePhase.ESCAPE, "POT_COOKING avanza a ESCAPE")
		_check(game.resolve_round(attacking_team, GameEnums.RoundEndReason.ESCAPE_SUCCESS), "el atacante gana la ronda de prueba")
		if round_index < GameStateNode.BEST_OF_ROUNDS - 2:
			_check(game.start_next_round(), "ROUND_RESULT permite iniciar la ronda siguiente antes de la quinta")
			game._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
	var scores: Dictionary = game.get_snapshot().scores
	_check(scores["TEAM_A"] == 2 and scores["TEAM_B"] == 2, "el marcador llega a 2-2 tras cuatro rondas")
	_check(game.start_next_round(), "se permite iniciar la quinta ronda")
	_check(game.get_snapshot().round_number == GameStateNode.BEST_OF_ROUNDS, "el número de ronda llega al máximo de cinco")
	game._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
	var fifth_round_attacker: int = int(game.get_snapshot().attacking_team)
	_check(game.capture_papa(), "la quinta ronda permite capturar Papa")
	_check(game.begin_pot_cooking(), "la quinta ronda permite cocinar Papa")
	game._process(GameStateNode.POT_COOKING_DURATION_SECONDS + 0.1)
	_check(game.resolve_round(fifth_round_attacker, GameEnums.RoundEndReason.ESCAPE_SUCCESS), "se resuelve la quinta ronda")
	_check(game.get_snapshot().phase == GameEnums.GamePhase.MATCH_RESULT, "tres puntos finalizan la partida al terminar la quinta ronda")
	_check(not game.start_next_round(), "no se permite una sexta ronda")
	game.queue_free()
	return failures.is_empty()


func _new_active_game() -> Variant:
	var game := GameStateNode.new()
	root.add_child(game)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	if not game.configure_lobby(roster) or not game.start_match():
		_check(false, "se puede preparar una partida para probar el temporizador")
		game.queue_free()
		return null
	game._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
	if game.get_snapshot().phase != GameEnums.GamePhase.ACTIVE:
		_check(false, "la cuenta regresiva entra en ACTIVE para los tests aislados")
		game.queue_free()
		return null
	return game


func _eliminate_attackers(game: Variant) -> bool:
	var attacker_ids: Array[int] = []
	for player in game.get_snapshot().players:
		if player.get("side", "") == "attacker":
			attacker_ids.append(int(player.peer_id))
	if attacker_ids.size() != 3:
		return false
	for peer_id in attacker_ids:
		for _hit_index in range(GameStateNode.STARTING_LIVES_PER_ATTACKER):
			if not game.register_attacker_hit(peer_id, false):
				return false
	return game.get_snapshot().phase in [GameEnums.GamePhase.ROUND_RESULT, GameEnums.GamePhase.MATCH_RESULT]


func _test_json_round_trip() -> bool:
	var original := MatchStateData.new()
	original.revision = 8
	original.phase = GameEnums.GamePhase.ESCAPE
	original.players.append({"peer_id": 11, "ready": true, "team": GameEnums.TeamSide.TEAM_A})
	original.scores = {"TEAM_A": 2, "TEAM_B": 1}
	original.round_number = 4
	original.attacking_team = GameEnums.TeamSide.TEAM_B
	original.round_time_remaining = 96.5
	original.papa_state = GameEnums.PapaState.COOKED
	var restored: Variant = MatchStateData.from_json(original.to_json())
	if restored == null:
		push_error("FAIL: JSON state round-trip returned null; payload=%s" % original.to_json())
		return false
	if restored.to_dictionary() != original.to_dictionary():
		push_error("FAIL: JSON round-trip mismatch; original=%s restored=%s" % [original.to_json(), restored.to_json()])
		return false
	var invalid_snapshot := original.to_dictionary()
	invalid_snapshot.phase = 99
	if MatchStateData.from_dictionary(invalid_snapshot) != null:
		push_error("FAIL: invalid schema must be rejected")
		return false
	return true


func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append("FAIL: " + label)


func _report_failures() -> void:
	for failure in failures:
		push_error(failure)


func _record_round_result(winner_team: int, reason: int, snapshot: Dictionary) -> void:
	observed_round_results.append({"winner": winner_team, "reason": reason, "snapshot": snapshot.duplicate(true)})


func _record_match_result(winner_team: int, snapshot: Dictionary) -> void:
	observed_match_results.append({"winner": winner_team, "snapshot": snapshot.duplicate(true)})
