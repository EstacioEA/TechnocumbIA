extends SceneTree

const PapaCaptureStateData = preload("res://scripts/combat/papa_capture_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var state = PapaCaptureStateData.new(true)
	assert(state.configure_round(10, [1, 2, 3], [3]))
	assert(state.request_capture(3))
	assert(state.carrier_id == 3)
	assert(state.papa_state == GameEnums.PapaState.CAPTURED)
	assert(is_equal_approx(state.immobilized_remaining, 20.0))

	assert(state.request_porta_papas_sprint(3))
	assert(is_equal_approx(state.immobilized_remaining, 18.0))
	state.tick(5.0)
	assert(is_equal_approx(state.immobilized_remaining, 13.0))

	assert(state.request_drop(3))
	assert(state.carrier_id == -1)
	assert(state.papa_state == GameEnums.PapaState.FREE)
	assert(is_equal_approx(state.carrier_stun_remaining, 3.0))
	assert(not state.request_capture(3))
	state.tick(3.0)
	assert(is_equal_approx(state.carrier_stun_remaining, 0.0))

	assert(state.request_capture(2))
	assert(state.request_hit_carrier(2))
	assert(state.carrier_id == -1)
	assert(state.papa_state == GameEnums.PapaState.FREE)
	assert(is_equal_approx(state.carrier_stun_remaining, 3.0))

	var client_state = PapaCaptureStateData.new(false)
	assert(not client_state.configure_round(10, [1, 2, 3], [3]))
	assert(not client_state.request_capture(3))
	print("papa_capture_state_test: PASS")
	quit(0)
