extends SceneTree

const GameScene = preload("res://scenes/game/papoi_game.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var session = GameScene.instantiate()
	root.add_child(session)
	await process_frame
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	_check(session.start_from_lobby_roster(roster), "host creates authoritative six-player role assignment")
	if _failures.size() > 0:
		_report_and_quit()
		return
	session.get_game_state()._process(4.0)

	var source: Dictionary = session.get_game_state().get_snapshot()
	var players: Array = source.get("players", [])
	var attacker_index := 0
	var defender_index := 0
	var beast_id := -1
	for player: Dictionary in players:
		if player.get("side", "") == "attacker":
			player["role"] = -1
			player["passive"] = attacker_index
			attacker_index += 1
		else:
			player["role"] = defender_index
			player["passive"] = -1
			if defender_index == GameEnums.DefenderRole.BESTIA:
				beast_id = int(player.peer_id)
			defender_index += 1
	_check(players.size() == 6 and beast_id > 0, "snapshot fixture covers the six supported role/passive identities")
	# The assignments above are deterministic test fixtures, not match rules or runtime data.
	session._beast_state.beast_id = beast_id
	# Inject deterministic host-owned test state to verify transport of a received timer.
	session._beast_state.cooldowns[&"beast_basic"] = 2.5
	var composed: Dictionary = session._compose_snapshot(source)
	var composed_players: Array = composed.get("players", [])
	_check(composed_players.size() == 6, "composed host snapshot retains all six players")
	for player: Dictionary in composed_players:
		_check(player.has("cooldowns") and player.cooldowns is Dictionary, "each player has an explicit cooldown payload")
		if int(player.peer_id) == beast_id:
			_check(float(player.cooldowns.get("beast_basic", -1.0)) == 2.5, "Bestia cooldown is copied from its host-owned model")
		else:
			_check(player.cooldowns.is_empty(), "unpublished cooldowns remain unavailable instead of being invented")
	var validated_state = MatchStateData.from_dictionary(composed)
	_check(validated_state != null, "authoritative snapshot passes the shared MatchState validator")
	var delivered: Dictionary = validated_state.to_dictionary() if validated_state != null else composed
	for player: Dictionary in delivered.get("players", []):
		_check(player.has("cooldowns"), "validated/serialized player retains cooldown payload")

	var hud: Node = session.get_node("HUD")
	for player: Dictionary in delivered.get("players", []):
		var local_snapshot := delivered.duplicate(true)
		local_snapshot["local_peer_id"] = int(player.peer_id)
		hud.apply_match_snapshot(local_snapshot)
		var expected_role: String = "ATACANTE" if int(player.role) == -1 else str(GameEnums.DefenderRole.keys()[int(player.role)])
		var expected_passive: String = "NINGUNA" if int(player.passive) == -1 else str(GameEnums.AttackerPassive.keys()[int(player.passive)])
		_check(hud.role_label.text == "ROL: %s" % expected_role, "HUD role matches authoritative player %s" % player.peer_id)
		_check(hud.passive_label.text == "PASIVA: %s" % expected_passive, "HUD passive matches authoritative player %s" % player.peer_id)
		if int(player.peer_id) == beast_id:
			_check(hud.cooldown_status_label.text.contains("BLOQUEADO · 2.5s"), "received Beast cooldown is visibly blocked with remaining time")
		else:
			_check(hud.cooldown_status_label.text == "ESTADO: sin datos", "missing cooldown stays explicitly unavailable")

	# Exercise every supported HUD role/passive identity independent of random match assignment.
	var six_role_cases: Array[Dictionary] = [
		{"role": -1, "passive": GameEnums.AttackerPassive.TANQUE, "label": "ATACANTE", "passive_label": "TANQUE"},
		{"role": -1, "passive": GameEnums.AttackerPassive.CAZADOR, "label": "ATACANTE", "passive_label": "CAZADOR"},
		{"role": -1, "passive": GameEnums.AttackerPassive.PORTA_PAPAS, "label": "ATACANTE", "passive_label": "PORTA_PAPAS"},
		{"role": GameEnums.DefenderRole.PAPA, "passive": -1, "label": "PAPA", "passive_label": "NINGUNA"},
		{"role": GameEnums.DefenderRole.TROLAZZO, "passive": -1, "label": "TROLAZZO", "passive_label": "NINGUNA"},
		{"role": GameEnums.DefenderRole.BESTIA, "passive": -1, "label": "BESTIA", "passive_label": "NINGUNA"},
	]
	for index in six_role_cases.size():
		var role_case: Dictionary = six_role_cases[index]
		var fixture := _hud_snapshot({
			"peer_id": 90,
			"role": role_case.role,
			"passive": role_case.passive,
			"lives": 3,
			"cooldowns": {"action": 0.0},
		})
		hud.apply_match_snapshot(fixture)
		_check(hud.role_label.text == "ROL: %s" % role_case.label, "HUD supports role/passive case %d" % index)
		_check(hud.passive_label.text == "PASIVA: %s" % role_case.passive_label, "HUD supports passive case %d" % index)
		_check(hud.cooldown_status_label.text == "ESTADO: action [✓ LISTO]", "received zero cooldown is visibly ready")

	hud.apply_match_snapshot(_hud_snapshot({"peer_id": 90, "cooldowns": "invalid"}))
	_check(hud.role_label.text == "ROL: SIN DATOS", "missing role is explicit")
	_check(hud.passive_label.text == "PASIVA: SIN DATOS", "missing passive is explicit")
	_check(hud.cooldown_status_label.text == "ESTADO: sin datos", "invalid cooldown payload is explicit")
	hud.apply_match_snapshot(_hud_snapshot({"peer_id": 90, "role": 88, "passive": -2, "cooldowns": {"trap": -1.0}}))
	_check(hud.role_label.text == "ROL: SIN DATOS", "invalid role enum is not presented as an attacker")
	_check(hud.passive_label.text == "PASIVA: SIN DATOS", "invalid passive enum is explicit")
	_check(hud.cooldown_status_label.text == "ESTADO: trap [? SIN DATOS]", "negative cooldown is not presented as ready")
	hud.apply_match_snapshot(_hud_snapshot({}, 91))
	_check(hud.lives_label.text == "VIDAS: sin datos", "missing local player clears stale lives")
	_check(hud.role_label.text == "ROL: SIN DATOS", "missing local player clears stale role")

	session.queue_free()
	await process_frame
	if _failures.is_empty():
		print("TC04_ROLE_SNAPSHOT_HUD_TEST: PASS")
		quit(0)
		return
	_report_and_quit()

func _hud_snapshot(player: Dictionary, local_peer_id: int = 90) -> Dictionary:
	return {
		"phase": GameEnums.GamePhase.ACTIVE,
		"round_number": 1,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 120.0,
		"scores": {"TEAM_A": 0, "TEAM_B": 0},
		"papa_state": GameEnums.PapaState.FREE,
		"local_peer_id": local_peer_id,
		"players": [player],
	}

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)

func _report_and_quit() -> void:
	for failure in _failures:
		push_error("TC04_ROLE_SNAPSHOT_HUD_TEST: " + failure)
	quit(1)
