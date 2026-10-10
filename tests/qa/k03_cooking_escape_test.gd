extends SceneTree

const CookingEscape = preload("res://scripts/objectives/papoi_cooking_escape.gd")
const PapaCapture = preload("res://scripts/combat/papa_capture_state.gd")
const BeastAccess = preload("res://scripts/combat/beast_access_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var capture = PapaCapture.new(true)
	var beast = BeastAccess.new(true)
	if not capture.configure_round(10, [1, 2, 3], []):
		_fail("capture state did not configure")
	if not beast.configure_round([6, 5, 4], [1, 2, 3]):
		_fail("beast access did not configure")
	var flow = CookingEscape.new(true, capture, beast)

	_check(not flow.start_cooking(true), "cooking rejects uncaptured Papa")
	_check(capture.request_capture(1), "host captures Papa")
	_check(not flow.start_cooking(false), "non-host cannot start cooking")
	_check(flow.start_cooking(true), "host starts cooking with captured Papa in pot")
	_check(flow.phase == flow.PHASE_POT_COOKING, "phase enters POT_COOKING")
	_check(beast.can_enter_pot_room(), "Bestia access opens while cooking")
	_check(not flow.rescue_by_beast(), "rescue requires Beast access permission")
	beast.tick(30.0)
	_check(beast.appeared, "Bestia appears before rescue")
	_check(flow.rescue_by_beast(), "Bestia rescues during cooking")
	_check(flow.phase == flow.PHASE_ACTIVE, "rescue returns objective to ACTIVE")
	_check(capture.papa_state == GameEnums.PapaState.FREE, "rescue releases Papa")

	_check(capture.request_capture(2), "Papa can be captured again")
	_check(flow.start_cooking(true), "host restarts cooking")
	_check(flow.advance_host_clock(29.9), "host advances cooking clock")
	_check(flow.phase == flow.PHASE_POT_COOKING, "cooking remains active before timer ends")
	_check(flow.advance_host_clock(0.1), "host completes cooking")
	_check(flow.phase == flow.PHASE_ESCAPE, "cooking transitions to ESCAPE")
	_check(flow.papa_state == GameEnums.PapaState.COOKED, "Papa state becomes COOKED")
	_check(not flow.reach_escape(Vector2(900.0, 384.0), Rect2(80.0, 288.0, 128.0, 192.0)), "escape rejects outside base")
	_check(flow.reach_escape(Vector2(120.0, 384.0), Rect2(80.0, 288.0, 128.0, 192.0)), "escape emits result at attacker base")

	if _failures.is_empty():
		print("K03_COOKING_ESCAPE_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("K03_COOKING_ESCAPE_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)

func _fail(message: String) -> void:
	_failures.append(message)
