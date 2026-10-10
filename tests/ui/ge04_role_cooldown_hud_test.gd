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
		"phase": GameEnums.GamePhase.ACTIVE,
		"round_number": 1,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 120.0,
		"scores": {"TEAM_A": 0, "TEAM_B": 0},
		"papa_state": GameEnums.PapaState.FREE,
		"local_peer_id": 7,
		"players": [{
			"peer_id": 7,
			"role": -1,
			"passive": GameEnums.AttackerPassive.PORTA_PAPAS,
			"lives": 3,
			"cooldowns": {"sprint": 1.5, "dash": 0.0},
		}],
	})
	_check(hud.role_label.text == "ROL: ATACANTE", "role is presented from the snapshot")
	_check(hud.passive_label.text == "PASIVA: PORTA_PAPAS", "passive is presented from the snapshot")
	_check(hud.cooldown_label.text == "COOLDOWNS: dash 0.0s, sprint 1.5s", "received cooldown data remains visible")
	_check(
		hud.cooldown_status_label.text == "ESTADO: dash [✓ LISTO]; sprint [! BLOQUEADO · 1.5s]",
		"ready and blocked states use text and symbols",
	)

	hud.set_player_context(3, "ATACANTE", "PORTA_PAPAS", {})
	_check(hud.cooldown_label.text == "COOLDOWNS: sin datos", "missing cooldowns remain marked as unavailable data")
	_check(hud.cooldown_status_label.text == "ESTADO: sin datos", "missing cooldown state is not guessed")

	if _failures.is_empty():
		print("GE04_ROLE_COOLDOWN_HUD_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GE04_ROLE_COOLDOWN_HUD_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
