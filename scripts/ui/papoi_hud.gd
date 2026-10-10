class_name PapoiHUD
extends CanvasLayer

const GameEnums = preload("res://scripts/shared/game_enums.gd")

var phase_label: Label
var round_label: Label
var timer_label: Label
var score_label: Label
var lives_label: Label
var role_label: Label
var passive_label: Label
var cooldown_label: Label
var objective_label: Label
var status_label: Label
var result_panel: PanelContainer
var result_label: Label

var _last_snapshot: Dictionary = {}

func _ready() -> void:
	_build_view()

func bind_objective_flow(flow: Node) -> void:
	if not flow.has_signal("state_changed"):
		push_error("PapoiHUD requiere un flujo con la señal state_changed.")
		return
	flow.state_changed.connect(apply_snapshot)
	if flow.has_method("get_snapshot"):
		apply_snapshot(flow.get_snapshot())

func bind_game_state(game_state: Node) -> void:
	if not game_state.has_signal("state_changed"):
		push_error("PapoiHUD requiere un GameState con la señal state_changed.")
		return
	game_state.state_changed.connect(apply_match_snapshot)
	if game_state.has_method("get_snapshot"):
		apply_match_snapshot(game_state.get_snapshot())

func apply_snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot.duplicate(true)
	var phase := str(snapshot.get("phase", "UNKNOWN"))
	phase_label.text = "FASE: %s" % phase
	round_label.text = "RONDA: %s" % str(snapshot.get("round", "-"))
	timer_label.text = "TIEMPO: %s" % _format_seconds(float(snapshot.get("round_time_remaining", 0.0)))
	var score: Dictionary = snapshot.get("score", {})
	score_label.text = "MARCADOR: ATACANTES %s - %s DEFENSORES" % [
		str(score.get("attackers", 0)),
		str(score.get("defenders", 0)),
	]
	objective_label.text = "OBJETIVO: %s" % str(snapshot.get("objective_text", "Sin objetivo"))
	status_label.text = "OLLA: %s" % (
		_FORMAT_COOKING if phase == "POT_COOKING" else "inactiva"
	)
	if phase == "POT_COOKING":
		status_label.text = "OLLA: COCIENDO (%s)" % _format_seconds(float(snapshot.get("cooking_time_remaining", 0.0)))

func apply_match_snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot.duplicate(true)
	var phase := int(snapshot.get("phase", GameEnums.GamePhase.LOBBY))
	phase_label.text = "FASE: %s" % _phase_text(phase)
	round_label.text = "RONDA: %s" % str(snapshot.get("round_number", "-"))
	timer_label.text = "RONDA: %s | FASE: %s" % [
		_format_seconds(float(snapshot.get("round_time_remaining", 0.0))),
		_format_seconds(float(snapshot.get("phase_time_remaining", 0.0))),
	]
	var scores: Dictionary = snapshot.get("scores", {})
	score_label.text = "MARCADOR: A %s - %s B" % [
		str(scores.get("TEAM_A", 0)),
		str(scores.get("TEAM_B", 0)),
	]
	var papa_state := int(snapshot.get("papa_state", GameEnums.PapaState.FREE))
	status_label.text = "PAPA: %s" % _papa_state_text(papa_state)
	if phase == GameEnums.GamePhase.POT_COOKING:
		status_label.text = "COCCIÓN: %s" % _format_seconds(float(snapshot.get("phase_time_remaining", 0.0)))
	elif phase == GameEnums.GamePhase.ESCAPE:
		status_label.text = "OBJETIVO: ESCAPA EN LA BASE ATACANTE"
	elif phase == GameEnums.GamePhase.ROUND_RESULT:
		show_round_result_from_snapshot(snapshot)
	elif phase == GameEnums.GamePhase.MATCH_RESULT:
		show_match_result_from_snapshot(snapshot)
	objective_label.text = "OBJETIVO: %s" % _objective_for_phase(phase, papa_state)
	_update_player_context_from_snapshot(snapshot)

func set_player_context(lives: int, role: String, passive: String, cooldowns: Dictionary) -> void:
	lives_label.text = "VIDAS: %d" % lives
	role_label.text = "ROL: %s" % role
	passive_label.text = "PASIVA: %s" % passive
	var cooldown_text := []
	for ability in cooldowns:
		cooldown_text.append("%s %.1fs" % [ability, float(cooldowns[ability])])
	cooldown_label.text = "COOLDOWNS: %s" % (", ".join(cooldown_text) if not cooldown_text.is_empty() else "listos")

func show_round_result(text: String) -> void:
	status_label.text = "RESULTADO DE RONDA: %s" % text
	_show_result("RESULTADO DE RONDA\n%s" % text)

func show_match_result(text: String) -> void:
	status_label.text = "RESULTADO DE PARTIDA: %s" % text
	_show_result("RESULTADO DE PARTIDA\n%s" % text)

func show_round_result_from_snapshot(snapshot: Dictionary) -> void:
	var reason := int(snapshot.get("round_end_reason", -1))
	var winner := int(snapshot.get("round_winner", -1))
	show_round_result("%s — %s" % [_winner_text(winner), _reason_text(reason)])

func show_match_result_from_snapshot(snapshot: Dictionary) -> void:
	var winner := int(snapshot.get("match_winner", -1))
	if int(snapshot.get("round_end_reason", -1)) == GameEnums.RoundEndReason.DISCONNECT:
		show_match_result("PARTIDA INVALIDADA POR DESCONEXIÓN")
	else:
		show_match_result(_winner_text(winner))

func set_connection_status(connected: bool, message: String = "") -> void:
	if connected:
		status_label.text = "CONEXIÓN: establecida"
	else:
		status_label.text = "CONEXIÓN: perdida%s" % (
			(" — " + message) if not message.is_empty() else ""
		)

func _build_view() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(20.0, 20.0)
	panel.size = Vector2(430.0, 210.0)
	add_child(panel)
	var content := VBoxContainer.new()
	panel.add_child(content)
	phase_label = _add_label(content)
	round_label = _add_label(content)
	timer_label = _add_label(content)
	score_label = _add_label(content)
	lives_label = _add_label(content)
	role_label = _add_label(content)
	passive_label = _add_label(content)
	cooldown_label = _add_label(content)
	objective_label = _add_label(content)
	status_label = _add_label(content)
	set_player_context(0, "sin asignar", "sin asignar", {})
	result_panel = PanelContainer.new()
	result_panel.position = Vector2(420.0, 260.0)
	result_panel.size = Vector2(440.0, 160.0)
	result_panel.visible = false
	add_child(result_panel)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_panel.add_child(result_label)

func _add_label(parent: Node) -> Label:
	var label := Label.new()
	parent.add_child(label)
	return label

func _format_seconds(seconds: float) -> String:
	var total := maxi(0, ceili(seconds))
	return "%02d:%02d" % [total / 60, total % 60]

func _update_player_context_from_snapshot(snapshot: Dictionary) -> void:
	var local_peer_id := int(snapshot.get("local_peer_id", -1))
	var players: Array = snapshot.get("players", [])
	for player in players:
		if int(player.get("peer_id", -1)) != local_peer_id:
			continue
		set_player_context(
			int(player.get("lives", 0)),
			_role_text(int(player.get("role", -1))),
			_passive_text(int(player.get("passive", -1))),
			player.get("cooldowns", {})
		)
		return

func _phase_text(phase: int) -> String:
	if phase < 0 or phase >= GameEnums.GamePhase.size():
		return "DESCONOCIDA"
	return GameEnums.GamePhase.keys()[phase]

func _papa_state_text(state: int) -> String:
	if state < 0 or state >= GameEnums.PapaState.size():
		return "DESCONOCIDA"
	return GameEnums.PapaState.keys()[state]

func _role_text(role: int) -> String:
	if role < 0:
		return "ATACANTE"
	if role >= GameEnums.DefenderRole.size():
		return "SIN ASIGNAR"
	return GameEnums.DefenderRole.keys()[role]

func _passive_text(passive: int) -> String:
	if passive < 0:
		return "NINGUNA"
	if passive >= GameEnums.AttackerPassive.size():
		return "SIN ASIGNAR"
	return GameEnums.AttackerPassive.keys()[passive]

func _winner_text(team: int) -> String:
	match team:
		GameEnums.TeamSide.TEAM_A:
			return "GANA EQUIPO A"
		GameEnums.TeamSide.TEAM_B:
			return "GANA EQUIPO B"
		_:
			return "SIN GANADOR"

func _reason_text(reason: int) -> String:
	match reason:
		GameEnums.RoundEndReason.ESCAPE_SUCCESS:
			return "escape completado"
		GameEnums.RoundEndReason.ATTACKERS_ELIMINATED:
			return "atacantes eliminados"
		GameEnums.RoundEndReason.TIME_EXPIRED:
			return "tiempo agotado"
		GameEnums.RoundEndReason.DISCONNECT:
			return "partida invalidada por desconexión"
		_:
			return "resultado pendiente"

func _objective_for_phase(phase: int, papa_state: int) -> String:
	match phase:
		GameEnums.GamePhase.LOBBY:
			return "Espera a que el host inicie."
		GameEnums.GamePhase.COUNTDOWN:
			return "Prepárate para la ronda."
		GameEnums.GamePhase.ACTIVE:
			return "Captura y transporta a Papa." if papa_state == GameEnums.PapaState.FREE else "Lleva Papa a la olla."
		GameEnums.GamePhase.POT_COOKING:
			return "Protege la olla durante la cocción."
		GameEnums.GamePhase.ESCAPE:
			return "Regresa a la base atacante."
		GameEnums.GamePhase.ROUND_RESULT:
			return "Espera el siguiente resultado del host."
		GameEnums.GamePhase.MATCH_RESULT:
			return "Partida terminada."
		_:
			return "Objetivo no disponible."

func _show_result(text: String) -> void:
	result_label.text = text
	result_panel.visible = true

const _FORMAT_COOKING := "cociendo"
