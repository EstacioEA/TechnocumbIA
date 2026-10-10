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
		"phase": GameEnums.GamePhase.POT_COOKING,
		"round_number": 2,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 18.0,
		"scores": {"TEAM_A": 1, "TEAM_B": 0},
		"papa_state": GameEnums.PapaState.BEING_COOKED,
		"players": [{
			"peer_id": 7,
			"role": -1,
			"passive": GameEnums.AttackerPassive.PORTA_PAPAS,
			"lives": 2,
			"cooldowns": {"sprint": 1.5},
		}],
		"local_peer_id": 7,
	})
	_check(hud.phase_label.text == "FASE: POT_COOKING", "phase is visible")
	_check(hud.round_label.text == "RONDA: 2", "round is visible")
	_check(hud.timer_label.text == "RONDA: 05:00 | FASE: 00:18", "round and phase timers are distinct")
	_check(hud.score_label.text == "MARCADOR: A 1 - 0 B", "score is visible")
	_check(hud.lives_label.text == "VIDAS: 2", "lives are visible")
	_check(hud.passive_label.text == "PASIVA: PORTA_PAPAS", "passive is visible")
	_check(hud.cooldown_label.text == "COOLDOWNS: sprint 1.5s", "cooldown is visible")
	_check(hud.status_label.text == "COCCIÓN: 00:18", "cooking timer is visible")

	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.ROUND_RESULT,
		"round_number": 2,
		"round_time_remaining": 0.0,
		"phase_time_remaining": 0.0,
		"scores": {"TEAM_A": 2, "TEAM_B": 0},
		"papa_state": GameEnums.PapaState.COOKED,
		"round_winner": GameEnums.TeamSide.TEAM_A,
		"round_end_reason": GameEnums.RoundEndReason.ESCAPE_SUCCESS,
	})
	_check(hud.result_panel.visible, "round result panel is visible")
	_check(hud.result_header_label.text == "RESULTADO DE RONDA · RONDA 2", "round result has a round-specific heading")
	_check(hud.result_label.text == "GANA EQUIPO A", "round winner is readable")
	_check(hud.result_detail_label.text == "escape completado", "round reason is readable")
	_check(hud.result_score_label.text == "MARCADOR DE SERIE: A 2 — 0 B", "round score is read from the snapshot")
	hud.set_connection_status(false, "host desconectado")
	_check(hud.status_label.text == "CONEXIÓN: perdida — host desconectado", "disconnect status is visible")

	if _failures.is_empty():
		print("K04_HUD_RESULTS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("K04_HUD_RESULTS_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
