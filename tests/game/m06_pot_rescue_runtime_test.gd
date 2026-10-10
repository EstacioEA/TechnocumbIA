extends SceneTree

const GameStateNode = preload("res://scripts/game/game_state.gd")
const CookingEscape = preload("res://scripts/objectives/papoi_cooking_escape.gd")
const PapaCapture = preload("res://scripts/combat/papa_capture_state.gd")
const BeastAccess = preload("res://scripts/combat/beast_access_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var capture := PapaCapture.new(true)
	var beast := BeastAccess.new(true)
	_check(capture.configure_round(10001, [1, 2, 3], []), "capture state configures the round")
	_check(beast.configure_round([6, 5, 4], [1, 2, 3]), "beast state configures the round")
	var flow := CookingEscape.new(true, capture, beast)

	_check(capture.request_capture(1), "attacker captures Papa")
	_check(flow.start_cooking(true), "carrier deposits Papa in the pot")
	_check(capture.carrier_id == -1, "deposit releases the carrier")
	_check(capture.papa_state == GameEnums.PapaState.BEING_COOKED, "deposit keeps Papa in cooking state")
	_check(is_equal_approx(flow.cooking_remaining, 20.0), "flow records duration without owning the clock")
	_check(not flow.rescue_by_beast(), "rescue rejects before Bestia appears")

	beast.tick(30.0)
	_check(flow.rescue_by_beast(), "Bestia rescues Papa during cooking")
	_check(flow.phase == flow.PHASE_ACTIVE, "rescue returns the flow to ACTIVE")
	_check(capture.papa_state == GameEnums.PapaState.FREE, "rescue leaves Papa free in the pot zone")

	_check(capture.request_capture(2), "attacker can capture Papa after rescue")
	_check(flow.start_cooking(true), "attacker can start a second cooking attempt")
	_check(flow.sync_from_game_snapshot({
		"phase": GameEnums.GamePhase.POT_COOKING,
		"phase_time_remaining": 0.01,
		"papa_state": GameEnums.PapaState.BEING_COOKED,
	}), "flow accepts the shared cooking snapshot")
	_check(flow.sync_from_game_snapshot({
		"phase": GameEnums.GamePhase.ESCAPE,
		"phase_time_remaining": 0.0,
		"papa_state": GameEnums.PapaState.COOKED,
	}), "flow accepts the completed cooking snapshot")
	_check(capture.papa_state == GameEnums.PapaState.COOKED, "completion marks Papa as cooked")

	var game := GameStateNode.new()
	root.add_child(game)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	_check(game.configure_lobby(roster), "GameState configures six peers")
	_check(game.start_match(), "GameState starts the round")
	game._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
	_check(game.capture_papa(), "GameState accepts capture in ACTIVE")
	_check(game.begin_pot_cooking(), "GameState accepts pot deposit")
	_check(is_equal_approx(game.get_snapshot().phase_time_remaining, 20.0), "GameState owns the exact 20 second clock")
	game._process(GameStateNode.POT_COOKING_DURATION_SECONDS)
	_check(game.get_snapshot().phase == GameEnums.GamePhase.ESCAPE, "GameState alone enables ESCAPE at zero")
	_check(game.get_snapshot().escape_available, "GameState enables the replicated exit flag")

	if _failures.is_empty():
		print("M06_POT_RESCUE_RUNTIME_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("M06_POT_RESCUE_RUNTIME_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
