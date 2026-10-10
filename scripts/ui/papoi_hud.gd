class_name PapoiHUD
extends CanvasLayer

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

func _show_result(text: String) -> void:
	result_label.text = text
	result_panel.visible = true

const _FORMAT_COOKING := "cociendo"
