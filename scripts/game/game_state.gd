extends Node
class_name GameState

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const GameRules = preload("res://scripts/shared/game_rules.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")

const REQUIRED_PLAYER_COUNT := 6
const BEST_OF_ROUNDS := 5
const POINTS_TO_WIN_MATCH := 3
const MAX_ROUND_DURATION_SECONDS := 7.0 * 60.0
const ROUND_DURATION_SECONDS := MAX_ROUND_DURATION_SECONDS
const COUNTDOWN_DURATION_SECONDS := 3.0 # Pendiente: confirmar duración de cuenta regresiva.
const POT_COOKING_DURATION_SECONDS := GameRules.POT_COOKING_DURATION_SECONDS
const STARTING_LIVES_PER_ATTACKER := 3 # Pendiente: persistir y consumir vidas al integrar combate.

signal phase_changed(previous_phase: int, current_phase: int)
signal state_changed(snapshot: Dictionary)
signal round_started(round_number: int, snapshot: Dictionary)
signal round_finished(winner_team: int, reason: int, snapshot: Dictionary)
signal match_finished(winner_team: int, snapshot: Dictionary)
signal players_changed(players: Array[Dictionary])
signal papa_state_changed(papa_state: int)
signal escape_availability_changed(available: bool)
signal warning_rejected(operation: String, reason: String)

var _state: MatchStateData = MatchStateData.new()
var _rng := RandomNumberGenerator.new()
var _round_resolved := false


func _ready() -> void:
	_rng.randomize()


func get_snapshot() -> Dictionary:
	return _state.to_dictionary()


func apply_host_snapshot(snapshot: Dictionary) -> bool:
	if multiplayer.is_server():
		return _reject("apply_host_snapshot", "el host no aplica snapshots de clientes")
	var parsed: MatchStateData = MatchStateData.from_dictionary(snapshot)
	if parsed == null:
		return _reject("apply_host_snapshot", "snapshot remoto inválido")
	if parsed.revision <= _state.revision:
		return _reject("apply_host_snapshot", "snapshot remoto obsoleto")
	var previous_phase := _state.phase
	var previous_papa_state := _state.papa_state
	var previous_escape_available := _state.escape_available
	var previous_players := _state.players.duplicate(true)
	_state = parsed
	if previous_phase != _state.phase:
		phase_changed.emit(previous_phase, _state.phase)
	if previous_papa_state != _state.papa_state:
		papa_state_changed.emit(_state.papa_state)
	if previous_escape_available != _state.escape_available:
		escape_availability_changed.emit(_state.escape_available)
	if previous_players != _state.players:
		players_changed.emit(_state.players.duplicate(true))
	state_changed.emit(get_snapshot())
	return true


func configure_lobby(roster: Array[Dictionary]) -> bool:
	if not _require_host("configure_lobby"):
		return false
	if _state.phase != GameEnums.GamePhase.LOBBY:
		return _reject("configure_lobby", "el lobby ya no está abierto")
	if roster.size() != REQUIRED_PLAYER_COUNT:
		return _reject("configure_lobby", "se requieren exactamente seis jugadores")
	var seen := {}
	var copied: Array[Dictionary] = []
	for player in roster:
		if not player.has("peer_id") or typeof(player.peer_id) != TYPE_INT or player.peer_id <= 0:
			return _reject("configure_lobby", "cada jugador requiere un peer_id entero positivo")
		if seen.has(player.peer_id):
			return _reject("configure_lobby", "peer_id duplicado")
		if not player.has("ready") or typeof(player.ready) != TYPE_BOOL or not player.ready:
			return _reject("configure_lobby", "todos los jugadores deben estar listos")
		seen[player.peer_id] = true
		copied.append({"peer_id": player.peer_id, "ready": true})
	copied.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.peer_id < b.peer_id)
	_state.players = copied
	var shuffled := [GameEnums.TeamSide.TEAM_A, GameEnums.TeamSide.TEAM_B]
	shuffled.shuffle()
	_state.attacking_team = shuffled[0]
	_emit_state()
	players_changed.emit(_state.players.duplicate(true))
	return true


func start_match() -> bool:
	if not _require_host("start_match"):
		return false
	if _state.phase != GameEnums.GamePhase.LOBBY or _state.players.size() != REQUIRED_PLAYER_COUNT:
		return _reject("start_match", "se requiere lobby válido con seis jugadores listos")
	if not _is_phase_transition_allowed(_state.phase, GameEnums.GamePhase.COUNTDOWN):
		return _reject("start_match", "transición de fase no permitida")
	_state.round_number = 1
	_assign_round_roles()
	_round_resolved = false
	_set_phase(GameEnums.GamePhase.COUNTDOWN)
	_state.phase_time_remaining = COUNTDOWN_DURATION_SECONDS
	_emit_state()
	return true


func capture_papa() -> bool:
	if not _require_host("capture_papa"):
		return false
	if _state.phase != GameEnums.GamePhase.ACTIVE or _state.papa_state != GameEnums.PapaState.FREE:
		return _reject("capture_papa", "Papa solo puede capturarse si está libre durante ACTIVE")
	_state.papa_state = GameEnums.PapaState.CAPTURED
	papa_state_changed.emit(_state.papa_state)
	_emit_state()
	return true


func register_attacker_hit(peer_id: int, was_carrying_papa: bool) -> bool:
	if not _require_host("register_attacker_hit"):
		return false
	if _state.phase not in [GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE]:
		return _reject("register_attacker_hit", "un golpe solo es válido durante una ronda activa")
	for player in _state.players:
		if player.peer_id != peer_id:
			continue
		if player.get("side", "") != "attacker":
			return _reject("register_attacker_hit", "el jugador indicado no es atacante")
		if was_carrying_papa:
			if _state.papa_state != GameEnums.PapaState.CAPTURED:
				return _reject("register_attacker_hit", "no se puede soltar Papa si no está siendo transportada")
			_state.papa_state = GameEnums.PapaState.FREE
			papa_state_changed.emit(_state.papa_state)
		else:
			player.lives = maxi(0, int(player.lives) - 1)
			if _all_attackers_eliminated():
				return resolve_round(_other_team(_state.attacking_team), GameEnums.RoundEndReason.ATTACKERS_ELIMINATED)
		_emit_state()
		return true
	return _reject("register_attacker_hit", "peer_id no pertenece al roster de la ronda")


func begin_pot_cooking() -> bool:
	if not _require_host("begin_pot_cooking"):
		return false
	if _state.phase != GameEnums.GamePhase.ACTIVE or _state.papa_state != GameEnums.PapaState.CAPTURED:
		return _reject("begin_pot_cooking", "la cocción requiere Papa capturada durante ACTIVE")
	_state.papa_state = GameEnums.PapaState.BEING_COOKED
	_set_escape_available(false)
	papa_state_changed.emit(_state.papa_state)
	_set_phase(GameEnums.GamePhase.POT_COOKING)
	_state.phase_time_remaining = POT_COOKING_DURATION_SECONDS
	_emit_state()
	return true


func cancel_pot_cooking() -> bool:
	if not _require_host("cancel_pot_cooking"):
		return false
	if _state.phase != GameEnums.GamePhase.POT_COOKING:
		return _reject("cancel_pot_cooking", "solo se puede cancelar una cocción activa")
	if not _is_phase_transition_allowed(_state.phase, GameEnums.GamePhase.ACTIVE):
		return _reject("cancel_pot_cooking", "transición de rescate no permitida")
	_state.papa_state = GameEnums.PapaState.FREE
	_set_escape_available(false)
	_state.phase_time_remaining = 0.0
	_set_phase(GameEnums.GamePhase.ACTIVE)
	papa_state_changed.emit(_state.papa_state)
	_emit_state()
	return true


func register_escape(attacker_peer_id: int) -> bool:
	if not _require_host("register_escape"):
		return false
	if _state.phase != GameEnums.GamePhase.ESCAPE or not _state.escape_available:
		return _reject("register_escape", "la salida no está habilitada")
	if _state.papa_state != GameEnums.PapaState.COOKED:
		return _reject("register_escape", "Papa debe estar cocinada para escapar")
	var is_attacker := false
	for player in _state.players:
		if int(player.get("peer_id", -1)) == attacker_peer_id:
			is_attacker = player.get("side", "") == "attacker" and int(player.get("team", -1)) == _state.attacking_team
			break
	if not is_attacker:
		return _reject("register_escape", "solo un atacante de la ronda puede escapar")
	return resolve_round(_state.attacking_team, GameEnums.RoundEndReason.ESCAPE_SUCCESS)


func resolve_round(winner_team: int, reason: int) -> bool:
	if not _require_host("resolve_round"):
		return false
	if _round_resolved:
		return _reject("resolve_round", "esta ronda ya fue resuelta")
	if not _is_phase_transition_allowed(_state.phase, GameEnums.GamePhase.ROUND_RESULT):
		return _reject("resolve_round", "la fase actual no permite resolver la ronda")
	if not _is_round_reason(reason):
		return _reject("resolve_round", "equipo ganador o motivo inválido")
	var is_disconnect_invalidation := reason == GameEnums.RoundEndReason.DISCONNECT
	if (is_disconnect_invalidation and winner_team != -1) or (not is_disconnect_invalidation and not _is_team(winner_team)):
		return _reject("resolve_round", "equipo ganador no coincide con el motivo")
	if not _is_resolution_valid(winner_team, reason):
		return _reject("resolve_round", "el resultado no corresponde a la fase o condición actual")
	_round_resolved = true
	_state.round_winner = winner_team
	_state.round_end_reason = reason
	_state.phase_time_remaining = 0.0
	_state.round_time_remaining = 0.0
	if is_disconnect_invalidation:
		_state.match_winner = -1
		_set_phase(GameEnums.GamePhase.ROUND_RESULT)
		_emit_state()
		round_finished.emit(-1, reason, get_snapshot())
		_set_phase(GameEnums.GamePhase.MATCH_RESULT)
		_emit_state()
		match_finished.emit(-1, get_snapshot())
		return true
	var score_key := MatchStateData.team_score_key(winner_team)
	_state.scores[score_key] = int(_state.scores[score_key]) + 1
	_set_phase(GameEnums.GamePhase.ROUND_RESULT)
	_emit_state()
	round_finished.emit(winner_team, reason, get_snapshot())
	if _state.scores[score_key] >= POINTS_TO_WIN_MATCH:
		_state.match_winner = winner_team
		_set_phase(GameEnums.GamePhase.MATCH_RESULT)
		_emit_state()
		match_finished.emit(winner_team, get_snapshot())
	return true


func start_next_round() -> bool:
	if not _require_host("start_next_round"):
		return false
	if _state.phase != GameEnums.GamePhase.ROUND_RESULT:
		return _reject("start_next_round", "solo se puede continuar desde ROUND_RESULT")
	if not _is_phase_transition_allowed(_state.phase, GameEnums.GamePhase.COUNTDOWN):
		return _reject("start_next_round", "transición de fase no permitida")
	if _state.round_number >= BEST_OF_ROUNDS:
		return _reject("start_next_round", "se alcanzó el máximo de cinco rondas")
	_state.round_number += 1
	_state.attacking_team = _other_team(_state.attacking_team)
	_state.round_winner = -1
	_state.round_end_reason = -1
	_state.papa_state = GameEnums.PapaState.FREE
	_set_escape_available(false)
	_round_resolved = false
	_assign_round_roles()
	_set_phase(GameEnums.GamePhase.COUNTDOWN)
	_state.phase_time_remaining = COUNTDOWN_DURATION_SECONDS
	_emit_state()
	return true


func _process(delta: float) -> void:
	var peer: MultiplayerPeer = multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if not multiplayer.is_server() or delta <= 0.0:
		return
	if _state.phase == GameEnums.GamePhase.COUNTDOWN:
		_state.phase_time_remaining = maxf(0.0, _state.phase_time_remaining - delta)
		if _state.phase_time_remaining <= 0.0:
			_state.round_time_remaining = ROUND_DURATION_SECONDS
			_set_phase(GameEnums.GamePhase.ACTIVE)
			round_started.emit(_state.round_number, get_snapshot())
			_emit_state()
	elif _state.phase == GameEnums.GamePhase.ACTIVE:
		_state.round_time_remaining = maxf(0.0, _state.round_time_remaining - delta)
		if _state.round_time_remaining <= 0.0:
			resolve_round(_other_team(_state.attacking_team), GameEnums.RoundEndReason.TIME_EXPIRED)
		else:
			_emit_state()
	elif _state.phase == GameEnums.GamePhase.POT_COOKING:
		_state.phase_time_remaining = maxf(0.0, _state.phase_time_remaining - delta)
		if _state.phase_time_remaining <= 0.0:
			_state.papa_state = GameEnums.PapaState.COOKED
			papa_state_changed.emit(_state.papa_state)
			_set_phase(GameEnums.GamePhase.ESCAPE)
			_set_escape_available(true)
			_state.phase_time_remaining = 0.0
			_emit_state()
		else:
			_emit_state()


func _assign_round_roles() -> void:
	var attacker_ids: Array[int] = []
	var defender_ids: Array[int] = []
	for i in range(_state.players.size()):
		var team := GameEnums.TeamSide.TEAM_A if i < 3 else GameEnums.TeamSide.TEAM_B
		if team == _state.attacking_team:
			attacker_ids.append(_state.players[i].peer_id)
		else:
			defender_ids.append(_state.players[i].peer_id)
	for player in _state.players:
		if player.peer_id in attacker_ids:
			player["team"] = _state.attacking_team
			player["side"] = "attacker"
			player["passive"] = _rng.randi_range(GameEnums.AttackerPassive.TANQUE, GameEnums.AttackerPassive.PORTA_PAPAS)
			player["lives"] = STARTING_LIVES_PER_ATTACKER
			player["role"] = -1
		else:
			player["team"] = _other_team(_state.attacking_team)
			player["side"] = "defender"
			player["role"] = _rng.randi_range(GameEnums.DefenderRole.PAPA, GameEnums.DefenderRole.BESTIA)
			player["passive"] = -1


func _all_attackers_eliminated() -> bool:
	for player in _state.players:
		if player.get("side", "") == "attacker" and int(player.get("lives", 0)) > 0:
			return false
	return true


func _is_resolution_valid(winner_team: int, reason: int) -> bool:
	var defending_team := _other_team(_state.attacking_team)
	match reason:
		GameEnums.RoundEndReason.ESCAPE_SUCCESS:
			return _state.phase == GameEnums.GamePhase.ESCAPE and _state.escape_available and _state.papa_state == GameEnums.PapaState.COOKED and winner_team == _state.attacking_team
		GameEnums.RoundEndReason.ATTACKERS_ELIMINATED:
			return _state.phase in [GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE] and winner_team == defending_team and _all_attackers_eliminated()
		GameEnums.RoundEndReason.TIME_EXPIRED:
			return _state.phase == GameEnums.GamePhase.ACTIVE and winner_team == defending_team and _state.round_time_remaining <= 0.0
		GameEnums.RoundEndReason.DISCONNECT:
			return winner_team == -1 and _state.phase in [GameEnums.GamePhase.COUNTDOWN, GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE]
	return false


func _set_phase(next_phase: int) -> bool:
	if not _require_host("set_phase"):
		return false
	var previous := _state.phase
	if not _is_phase_transition_allowed(previous, next_phase):
		return _reject("set_phase", "transición inválida: %s -> %s" % [previous, next_phase])
	if next_phase == GameEnums.GamePhase.ACTIVE and _state.phase_time_remaining > 0.0:
		return _reject("set_phase", "la cuenta regresiva aún no termina")
	if next_phase == GameEnums.GamePhase.COUNTDOWN and previous == GameEnums.GamePhase.ROUND_RESULT:
		if _state.match_winner != -1 or (_state.round_number >= BEST_OF_ROUNDS and _round_resolved):
			return _reject("set_phase", "la partida ya terminó o alcanzó el máximo de rondas")
	if next_phase == GameEnums.GamePhase.MATCH_RESULT:
		if _state.round_end_reason == GameEnums.RoundEndReason.DISCONNECT:
			if _state.match_winner != -1 or not _round_resolved:
				return _reject("set_phase", "la invalidación requiere una desconexión no recuperable")
		else:
			if not _is_team(_state.match_winner):
				return _reject("set_phase", "MATCH_RESULT requiere un ganador autoritativo")
			var score_key := MatchStateData.team_score_key(_state.match_winner)
			if int(_state.scores.get(score_key, 0)) < POINTS_TO_WIN_MATCH:
				return _reject("set_phase", "el ganador todavía no alcanza tres puntos")
	_state.phase = next_phase
	_state.revision += 1
	phase_changed.emit(previous, next_phase)
	return true


func _is_phase_transition_allowed(previous_phase: int, next_phase: int) -> bool:
	match previous_phase:
		GameEnums.GamePhase.LOBBY:
			return next_phase == GameEnums.GamePhase.COUNTDOWN
		GameEnums.GamePhase.COUNTDOWN:
			return next_phase in [GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.ROUND_RESULT]
		GameEnums.GamePhase.ACTIVE:
			return next_phase in [GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ROUND_RESULT]
		GameEnums.GamePhase.POT_COOKING:
			return next_phase in [GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.ESCAPE, GameEnums.GamePhase.ROUND_RESULT]
		GameEnums.GamePhase.ESCAPE:
			return next_phase == GameEnums.GamePhase.ROUND_RESULT
		GameEnums.GamePhase.ROUND_RESULT:
			return next_phase in [GameEnums.GamePhase.COUNTDOWN, GameEnums.GamePhase.MATCH_RESULT]
		GameEnums.GamePhase.MATCH_RESULT:
			return false
	return false


func _emit_state() -> void:
	_state.revision += 1
	state_changed.emit(get_snapshot())


func _set_escape_available(available: bool) -> void:
	if _state.escape_available == available:
		return
	_state.escape_available = available
	escape_availability_changed.emit(available)


func _require_host(operation: String) -> bool:
	if multiplayer.is_server():
		return true
	return _reject(operation, "solo el host puede cambiar el estado autoritativo")


func _reject(operation: String, reason: String) -> bool:
	warning_rejected.emit(operation, reason)
	push_warning("GameState.%s rechazado: %s" % [operation, reason])
	return false


func _is_team(team: int) -> bool:
	return team == GameEnums.TeamSide.TEAM_A or team == GameEnums.TeamSide.TEAM_B


func _is_round_reason(reason: int) -> bool:
	return reason >= GameEnums.RoundEndReason.ESCAPE_SUCCESS and reason <= GameEnums.RoundEndReason.DISCONNECT


func _other_team(team: int) -> int:
	return GameEnums.TeamSide.TEAM_B if team == GameEnums.TeamSide.TEAM_A else GameEnums.TeamSide.TEAM_A
