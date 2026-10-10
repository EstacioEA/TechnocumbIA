extends SceneTree

const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var hud = HUD_SCENE.instantiate()
	root.add_child(hud)
	await process_frame
	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.ROUND_RESULT,
		"round_number": 3,
		"scores": {"TEAM_A": 2, "TEAM_B": 1},
		"round_winner": GameEnums.TeamSide.TEAM_A,
		"round_end_reason": GameEnums.RoundEndReason.ESCAPE_SUCCESS,
	})
	_check(hud.result_panel.visible, "round card is visible")
	_check(hud.result_header_label.text == "RESULTADO DE RONDA · RONDA 3", "round result names its round")
	_check(hud.result_label.text == "GANA EQUIPO A", "round winner is supplied by the snapshot")
	_check(hud.result_detail_label.text == "escape completado", "round reason is supplied by the snapshot")
	_check(hud.result_score_label.text == "MARCADOR DE SERIE: A 2 — 1 B", "round card shows received series score")
	var round_card_size: Vector2 = hud.result_panel.custom_minimum_size

	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.MATCH_RESULT,
		"round_number": 5,
		"scores": {"TEAM_A": 2, "TEAM_B": 3},
		"match_winner": GameEnums.TeamSide.TEAM_B,
		"round_end_reason": -1,
	})
	_check(hud.result_header_label.text == "RESULTADO FINAL DE PARTIDA", "match result has a distinct heading")
	_check(hud.result_label.text == "GANA EQUIPO B", "match winner is supplied by the snapshot")
	_check(hud.result_score_label.text == "MARCADOR FINAL: A 2 — 3 B", "match card shows received final score")
	_check(hud.result_panel.custom_minimum_size.x > round_card_size.x, "match card has a stronger visual hierarchy")

	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.MATCH_RESULT,
		"round_number": 1,
		"scores": {"TEAM_A": 0, "TEAM_B": 0},
		"match_winner": -1,
		"round_end_reason": GameEnums.RoundEndReason.DISCONNECT,
	})
	_check(hud.result_label.text == "PARTIDA INVALIDADA", "disconnect is not shown as a winner")
	_check(hud.result_detail_label.text == "Desconexión detectada por GameState.", "disconnect cause is explicit")

	if _failures.is_empty():
		print("GE05_RESULT_HIERARCHY_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GE05_RESULT_HIERARCHY_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
