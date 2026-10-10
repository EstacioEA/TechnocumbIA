class_name PapoiHUD
extends CanvasLayer

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const RESULT_CARD_SCENE := preload("res://scenes/ui/papoi_result_card.tscn")

var phase_label: Label
var phase_tag_label: Label
var round_label: Label
var timer_label: Label
var score_label: Label
var lives_label: Label
var role_label: Label
var passive_label: Label
var cooldown_label: Label
var cooldown_status_label: Label
var objective_label: Label
var status_label: Label
var result_panel: PanelContainer
var result_label: Label
var result_header_label: Label
var result_detail_label: Label
var result_score_label: Label
var result_overlay: ColorRect
var status_panel: PanelContainer
var result_card: PapoiResultCard

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
	phase_tag_label.text = _phase_tag_name(phase)
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
	result_panel.visible = false
	result_overlay.visible = false
	var phase := int(snapshot.get("phase", GameEnums.GamePhase.LOBBY))
	status_panel.visible = phase != GameEnums.GamePhase.ROUND_RESULT and phase != GameEnums.GamePhase.MATCH_RESULT
	phase_label.text = "FASE: %s" % _phase_text(phase)
	phase_tag_label.text = _phase_tag(phase)
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
	var cooldown_text: Array[String] = []
	var cooldown_status: Array[String] = []
	# TODO(GM01): confirmar fuente y unidades del cooldown; el HUD solo presenta datos recibidos.
	var abilities: Array = cooldowns.keys()
	abilities.sort()
	for ability in abilities:
		var remaining: Variant = cooldowns[ability]
		if typeof(remaining) != TYPE_FLOAT and typeof(remaining) != TYPE_INT:
			cooldown_text.append("%s sin datos" % ability)
			cooldown_status.append("%s [? SIN DATOS]" % ability)
			continue
		var seconds := float(remaining)
		if not is_finite(seconds) or seconds < 0.0:
			cooldown_text.append("%s sin datos" % ability)
			cooldown_status.append("%s [? SIN DATOS]" % ability)
		elif seconds > 0.0:
			cooldown_text.append("%s %.1fs" % [ability, seconds])
			cooldown_status.append("%s [! BLOQUEADO · %.1fs]" % [ability, seconds])
		else:
			cooldown_text.append("%s 0.0s" % ability)
			cooldown_status.append("%s [✓ LISTO]" % ability)
	cooldown_label.text = "COOLDOWNS: %s" % (
		", ".join(cooldown_text) if not cooldown_text.is_empty() else "sin datos"
	)
	cooldown_status_label.text = "ESTADO: %s" % (
		"; ".join(cooldown_status) if not cooldown_status.is_empty() else "sin datos"
	)

func show_round_result(text: String) -> void:
	status_label.text = "RESULTADO DE RONDA: %s" % text
	status_panel.visible = false
	result_card.present_round_result("-", text, "", {})
	_show_result()

func show_match_result(text: String) -> void:
	status_label.text = "RESULTADO DE PARTIDA: %s" % text
	status_panel.visible = false
	result_card.present_match_result(text, "", {})
	_show_result()

func show_round_result_from_snapshot(snapshot: Dictionary) -> void:
	var reason := int(snapshot.get("round_end_reason", -1))
	var winner := int(snapshot.get("round_winner", -1))
	status_label.text = "RESULTADO DE RONDA: %s" % _winner_text(winner)
	status_panel.visible = false
	result_card.present_round_result(
		str(snapshot.get("round_number", "-")),
		_winner_text(winner),
		_reason_text(reason),
		snapshot.get("scores", {})
	)
	_show_result()

func show_match_result_from_snapshot(snapshot: Dictionary) -> void:
	var winner := int(snapshot.get("match_winner", -1))
	if int(snapshot.get("round_end_reason", -1)) == GameEnums.RoundEndReason.DISCONNECT:
		status_label.text = "PARTIDA INVALIDADA POR DESCONEXIÓN"
		result_card.present_match_result(
			"PARTIDA INVALIDADA",
			"Desconexión detectada por GameState.",
			snapshot.get("scores", {})
		)
	else:
		status_label.text = "RESULTADO DE PARTIDA: %s" % _winner_text(winner)
		result_card.present_match_result(
			_winner_text(winner),
			"Partida completada.",
			snapshot.get("scores", {})
		)
	status_panel.visible = false
	_show_result()

func set_connection_status(connected: bool, message: String = "") -> void:
	if connected:
		status_label.text = "CONEXIÓN: establecida"
	else:
		status_label.text = "CONEXIÓN: perdida%s" % (
			(" — " + message) if not message.is_empty() else ""
		)

func _build_view() -> void:
	var ui_root := Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_root.theme = load("res://scenes/ui/papoi_theme.tres")
	add_child(ui_root)

	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_top", 16)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_bottom", 16)
	ui_root.add_child(margins)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margins.add_child(layout)

	var top_bar := PanelContainer.new()
	top_bar.custom_minimum_size.y = 56.0
	_apply_compact_panel_margins(top_bar, 16.0, 5.0)
	layout.add_child(top_bar)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 20)
	top_bar.add_child(top_row)

	var phase_group := VBoxContainer.new()
	phase_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_group.add_theme_constant_override("separation", 2)
	top_row.add_child(phase_group)
	var phase_heading := HBoxContainer.new()
	phase_heading.add_theme_constant_override("separation", 12)
	phase_group.add_child(phase_heading)
	phase_label = _add_label(phase_heading)
	phase_label.add_theme_font_size_override("font_size", 20)
	phase_tag_label = _add_label(phase_heading)
	phase_tag_label.add_theme_font_size_override("font_size", 14)
	objective_label = _add_label(phase_group)
	objective_label.add_theme_font_size_override("font_size", 14)

	timer_label = _add_label(top_row)
	round_label = _add_label(top_row)
	score_label = _add_label(top_row)
	timer_label.add_theme_font_size_override("font_size", 16)
	round_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_font_size_override("font_size", 18)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 16)
	layout.add_child(bottom_row)

	var player_panel := PanelContainer.new()
	player_panel.custom_minimum_size.x = 340.0
	_apply_compact_panel_margins(player_panel, 16.0, 12.0)
	bottom_row.add_child(player_panel)
	var player_context := VBoxContainer.new()
	player_context.add_theme_constant_override("separation", 4)
	player_panel.add_child(player_context)
	lives_label = _add_label(player_context)
	role_label = _add_label(player_context)
	passive_label = _add_label(player_context)
	cooldown_label = _add_label(player_context)
	cooldown_status_label = _add_label(player_context)
	cooldown_status_label.add_theme_font_size_override("font_size", 12)
	cooldown_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(bottom_spacer)

	status_panel = PanelContainer.new()
	status_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	status_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	_apply_compact_panel_margins(status_panel, 16.0, 12.0)
	bottom_row.add_child(status_panel)
	status_label = _add_label(status_panel)
	status_label.add_theme_font_size_override("font_size", 16)

	set_player_context(0, "sin asignar", "sin asignar", {})

	result_overlay = ColorRect.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.color = ui_root.theme.get_color("ui_overlay", "PapoiTokens")
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.z_index = 10
	result_overlay.visible = false
	ui_root.add_child(result_overlay)

	var result_center := CenterContainer.new()
	result_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.add_child(result_center)
	result_card = RESULT_CARD_SCENE.instantiate() as PapoiResultCard
	result_card.visible = false
	result_center.add_child(result_card)
	result_panel = result_card
	result_header_label = result_card.header_label
	result_label = result_card.primary_label
	result_detail_label = result_card.detail_label
	result_score_label = result_card.score_label

	# El modal oscurece el mundo; el HUD queda arriba y sigue legible.
	margins.z_index = 20

func _add_label(parent: Node) -> Label:
	var label := Label.new()
	parent.add_child(label)
	return label

func _apply_compact_panel_margins(panel: PanelContainer, horizontal: float, vertical: float) -> void:
	panel.theme = load("res://scenes/ui/papoi_theme.tres")
	var panel_style := panel.get_theme_stylebox("panel", "PanelContainer").duplicate() as StyleBoxFlat
	panel_style.content_margin_left = horizontal
	panel_style.content_margin_right = horizontal
	panel_style.content_margin_top = vertical
	panel_style.content_margin_bottom = vertical
	panel.add_theme_stylebox_override("panel", panel_style)

func _format_seconds(seconds: float) -> String:
	var total := maxi(0, ceili(seconds))
	return "%02d:%02d" % [total / 60, total % 60]

func _update_player_context_from_snapshot(snapshot: Dictionary) -> void:
	var local_peer_id := int(snapshot.get("local_peer_id", -1))
	var players: Array = snapshot.get("players", [])
	for player in players:
		if not player is Dictionary:
			continue
		if int(player.get("peer_id", -1)) != local_peer_id:
			continue
		var cooldowns: Variant = player.get("cooldowns", {})
		if not cooldowns is Dictionary:
			cooldowns = {}
		set_player_context(
			int(player.get("lives", -1)),
			_role_context_text(player),
			_passive_context_text(player),
			cooldowns
		)
		return
	_clear_player_context()

func _clear_player_context() -> void:
	lives_label.text = "VIDAS: sin datos"
	role_label.text = "ROL: SIN DATOS"
	passive_label.text = "PASIVA: SIN DATOS"
	cooldown_label.text = "COOLDOWNS: sin datos"
	cooldown_status_label.text = "ESTADO: sin datos"

func _role_context_text(player: Dictionary) -> String:
	if not player.has("role") or not _is_integer_value(player["role"]):
		return "SIN DATOS"
	var role := int(player["role"])
	if role == -1:
		return "ATACANTE"
	if role < 0 or role >= GameEnums.DefenderRole.size():
		return "SIN DATOS"
	return GameEnums.DefenderRole.keys()[role]

func _passive_context_text(player: Dictionary) -> String:
	if not player.has("passive") or not _is_integer_value(player["passive"]):
		return "SIN DATOS"
	var passive := int(player["passive"])
	if passive == -1:
		return "NINGUNA"
	if passive < 0 or passive >= GameEnums.AttackerPassive.size():
		return "SIN DATOS"
	return GameEnums.AttackerPassive.keys()[passive]

func _is_integer_value(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or (
		typeof(value) == TYPE_FLOAT and is_finite(value) and is_equal_approx(value, round(value))
	)

func _phase_text(phase: int) -> String:
	if phase < 0 or phase >= GameEnums.GamePhase.size():
		return "DESCONOCIDA"
	return GameEnums.GamePhase.keys()[phase]

func _phase_tag(phase: int) -> String:
	match phase:
		GameEnums.GamePhase.ACTIVE:
			return "▶ PARTIDA EN CURSO"
		GameEnums.GamePhase.POT_COOKING:
			return "♨ PAPA EN COCCIÓN"
		GameEnums.GamePhase.ESCAPE:
			return "➜ ESCAPE"
		_:
			return ""

func _phase_tag_name(phase: String) -> String:
	match phase:
		"ACTIVE":
			return "▶ PARTIDA EN CURSO"
		"POT_COOKING":
			return "♨ PAPA EN COCCIÓN"
		"ESCAPE":
			return "➜ ESCAPE"
		_:
			return ""

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

func _show_result() -> void:
	result_overlay.visible = true
	result_card.visible = true

const _FORMAT_COOKING := "cociendo"
