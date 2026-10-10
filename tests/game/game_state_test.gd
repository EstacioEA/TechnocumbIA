extends SceneTree

const GameStateNode = preload("res://scripts/game/game_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	if not _test_json_round_trip():
		quit(1)
		return
	var game := GameStateNode.new()
	root.add_child(game)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	_check(game.configure_lobby(roster), "se configura un lobby con seis jugadores listos")
	_check(game.start_match(), "el host inicia la partida")
	game._process(4.0)
	_check(game.get_snapshot().phase == GameEnums.GamePhase.ACTIVE, "COUNTDOWN transiciona a ACTIVE")
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
	for expected_round in range(2, 5):
		_check(game.start_next_round(), "inicia la siguiente ronda")
		game._process(4.0)
		var snapshot: Dictionary = game.get_snapshot()
		_check(snapshot.round_number == expected_round, "número de ronda esperado")
		var expected_attack: int = 1 - first_attack if expected_round % 2 == 0 else first_attack
		_check(snapshot.attacking_team == expected_attack, "los lados alternan cada ronda")
		_check(game.resolve_round(1 - snapshot.attacking_team, GameEnums.RoundEndReason.ATTACKERS_ELIMINATED), "eliminación de atacantes resuelve ronda")
	_check(game.get_snapshot().phase == GameEnums.GamePhase.MATCH_RESULT, "tres puntos finalizan la partida")
	_check(game.get_snapshot().match_winner == first_attack, "ganador de partida correcto")
	_check(not game.start_next_round(), "no inicia una ronda después de MATCH_RESULT")
	if failures.is_empty():
		print("PASS: game state system")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


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
