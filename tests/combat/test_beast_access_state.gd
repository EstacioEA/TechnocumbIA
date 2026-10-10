extends SceneTree

const BeastAccessStateData = preload("res://scripts/combat/beast_access_state.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var state = BeastAccessStateData.new(true)
	assert(state.configure_round([6], [1, 2, 3]))
	assert(not state.appeared)
	assert(not state.request_basic_attack(1))
	assert(not state.can_enter_pot_room())

	state.tick(29.9)
	assert(not state.appeared)
	state.tick(0.1)
	assert(state.appeared)
	assert(not state.can_enter_pot_room())
	assert(state.request_basic_attack(1))
	assert(not state.request_basic_attack(1))
	state.tick(5.0)
	assert(state.request_basic_attack(1))
	assert(state.request_special_attack(2))
	assert(not state.request_special_attack(2))
	state.tick(10.0)
	assert(state.request_special_attack(2))

	assert(state.set_pot_cooking(true))
	assert(state.can_enter_pot_room())
	assert(state.set_pot_cooking(false))
	assert(not state.can_enter_pot_room())

	var client_state = BeastAccessStateData.new(false)
	assert(not client_state.configure_round([6], [1, 2, 3]))
	assert(not client_state.set_pot_cooking(true))
	print("beast_access_state_test: PASS")
	quit(0)
