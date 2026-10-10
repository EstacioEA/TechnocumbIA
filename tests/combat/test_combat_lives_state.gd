extends SceneTree

const CombatLivesStateData = preload("res://scripts/combat/combat_lives_state.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var state = CombatLivesStateData.new(true)
	assert(state.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3]))

	assert(state.request_hit_without_papa(1, false))
	assert(state.get_player_state(1)["lives"] == 2)
	assert(state.get_player_state(1)["active"] == false)
	assert(is_equal_approx(state.get_player_state(1)["respawn_remaining"], 3.0))
	state.tick(2.9)
	assert(state.get_player_state(1)["active"] == false)
	state.tick(0.1)
	assert(state.get_player_state(1)["active"] == true)
	assert(state.get_player_state(1)["lives"] == 2)

	assert(not state.request_hit_without_papa(2, true))
	assert(state.get_player_state(2)["lives"] == 3)
	assert(state.request_hit_without_papa(2, false))
	state.tick(3.0)
	assert(state.request_hit_without_papa(2, false))
	state.tick(3.0)
	assert(state.request_hit_without_papa(2, false))
	assert(state.get_player_state(2)["lives"] == 0)
	assert(state.should_defenders_win() == false)
	assert(state.request_hit_without_papa(1, false))
	state.tick(3.0)
	assert(state.request_hit_without_papa(1, false))
	assert(state.request_hit_without_papa(3, false))
	state.tick(3.0)
	assert(state.request_hit_without_papa(3, false))
	state.tick(3.0)
	assert(state.request_hit_without_papa(3, false))
	assert(state.should_defenders_win())

	assert(state.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3]))
	assert(state.get_player_state(1)["lives"] == 3)
	assert(state.get_player_state(2)["lives"] == 3)
	assert(not state.should_defenders_win())

	var client_state = CombatLivesStateData.new(false)
	assert(not client_state.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3]))
	print("combat_lives_state_test: PASS")
	quit(0)
