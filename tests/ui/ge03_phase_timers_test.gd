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
	var snapshot := {
		"round_number": 2,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 18.0,
		"scores": {"TEAM_A": 1, "TEAM_B": 0},
		"players": [],
	}

	snapshot["phase"] = GameEnums.GamePhase.ACTIVE
	snapshot["papa_state"] = GameEnums.PapaState.FREE
	hud.apply_match_snapshot(snapshot)
	_check(hud.phase_tag_label.text == "▶ PARTIDA EN CURSO", "ACTIVE has a distinct phase tag")
	_check(hud.timer_label.text == "RONDA: 05:00 | FASE: 00:18", "round and phase clocks remain separate")

	snapshot["phase"] = GameEnums.GamePhase.POT_COOKING
	snapshot["papa_state"] = GameEnums.PapaState.BEING_COOKED
	hud.apply_match_snapshot(snapshot)
	_check(hud.phase_tag_label.text == "♨ PAPA EN COCCIÓN", "POT_COOKING has a distinct phase tag")
	_check(hud.status_label.text == "COCCIÓN: 00:18", "cooking clock is explicitly labeled")
	_check(hud.timer_label.text == "RONDA: 05:00 | FASE: 00:18", "cooking does not overwrite the round clock")

	snapshot["phase"] = GameEnums.GamePhase.ESCAPE
	snapshot["papa_state"] = GameEnums.PapaState.COOKED
	hud.apply_match_snapshot(snapshot)
	_check(hud.phase_tag_label.text == "➜ ESCAPE", "ESCAPE has a distinct phase tag")
	_check(hud.timer_label.text == "RONDA: 05:00 | FASE: 00:18", "escape preserves separate clocks")

	if _failures.is_empty():
		print("GE03_PHASE_TIMERS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GE03_PHASE_TIMERS_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
