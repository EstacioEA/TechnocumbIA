class_name PapoiResultCard
extends PanelContainer

var header_label: Label
var primary_label: Label
var detail_label: Label
var score_label: Label

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	custom_minimum_size = Vector2(600.0, 232.0)
	var panel_style := get_theme_stylebox("panel", "PanelContainer").duplicate() as StyleBoxFlat
	panel_style.content_margin_left = 32.0
	panel_style.content_margin_right = 32.0
	panel_style.content_margin_top = 22.0
	panel_style.content_margin_bottom = 22.0
	add_theme_stylebox_override("panel", panel_style)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	add_child(content)
	header_label = _make_label(content, 17)
	header_label.add_theme_color_override("font_color", theme.get_color("ui_accent", "PapoiTokens"))
	primary_label = _make_label(content, 30)
	detail_label = _make_label(content, 18)
	score_label = _make_label(content, 16)
	score_label.add_theme_color_override("font_color", theme.get_color("ui_text", "PapoiTokens"))

func present_round_result(round_number: String, winner: String, reason: String, scores: Dictionary) -> void:
	custom_minimum_size = Vector2(600.0, 232.0)
	header_label.text = "RESULTADO DE RONDA · RONDA %s" % round_number
	primary_label.text = winner
	detail_label.text = reason
	detail_label.visible = not reason.is_empty()
	score_label.text = "MARCADOR DE SERIE: A %s — %s B" % [
		str(scores.get("TEAM_A", "-")),
		str(scores.get("TEAM_B", "-")),
	]

func present_match_result(winner_or_state: String, detail: String, scores: Dictionary) -> void:
	custom_minimum_size = Vector2(680.0, 270.0)
	header_label.text = "RESULTADO FINAL DE PARTIDA"
	primary_label.text = winner_or_state
	detail_label.text = detail
	detail_label.visible = not detail.is_empty()
	score_label.text = "MARCADOR FINAL: A %s — %s B" % [
		str(scores.get("TEAM_A", "-")),
		str(scores.get("TEAM_B", "-")),
	]

func _make_label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
