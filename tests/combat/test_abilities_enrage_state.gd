extends SceneTree

const AbilitiesEnrageStateData = preload("res://scripts/abilities/abilities_enrage_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var state = AbilitiesEnrageStateData.new(true)
	assert(state.configure_round(
		{6: GameEnums.DefenderRole.TROLAZZO},
		{
			1: GameEnums.AttackerPassive.TANQUE,
			2: GameEnums.AttackerPassive.CAZADOR,
			3: GameEnums.AttackerPassive.PORTA_PAPAS,
		},
		6
	))

	assert(state.request_trollazzo_trap(6, Vector2(10, 20)))
	assert(not state.request_trollazzo_trap(6, Vector2.ZERO))
	assert(state.get_trap_damage_multiplier(1) == 0.5)
	assert(state.get_beast_damage_multiplier(2) == 1.25)
	assert(state.get_porta_papas_sprint_reduction(3) == 2.0)
	assert(state.get_porta_papas_sprint_reduction(1) == 0.0)
	state.tick(8.0)
	assert(state.request_trollazzo_trap(6, Vector2.ZERO))

	assert(not state.beast_enraged)
	assert(state.get_beast_cooldown(10.0) == 10.0)
	assert(state.request_cooking_completed())
	assert(state.beast_enraged)
	assert(state.get_snapshot()["beast_speed_multiplier"] == 1.25)
	assert(state.get_beast_cooldown(10.0) == 5.0)
	assert(state.get_beast_cooldown(-2.0) == 0.0)

	var client_state = AbilitiesEnrageStateData.new(false)
	assert(not client_state.configure_round({}, {}, 6))
	assert(not client_state.request_cooking_completed())
	print("abilities_enrage_state_test: PASS")
	quit(0)
