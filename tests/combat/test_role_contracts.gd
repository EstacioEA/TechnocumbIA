extends SceneTree

const RoleContractsData = preload("res://scripts/roles/role_contracts.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var contracts = RoleContractsData.new(true)
	var assignments: Dictionary = contracts.assign_round(
		[1, 2, 3, 4, 5, 6],
		[1, 2, 3],
		[4, 5, 6],
		rng
	)
	assert(assignments.players.size() == 6)
	for player in assignments.players:
		assert(player.has("peer_id"))
		if player.team == GameEnums.TeamSide.TEAM_A:
			assert(player.passive >= GameEnums.AttackerPassive.TANQUE)
			assert(player.passive <= GameEnums.AttackerPassive.PORTA_PAPAS)
			assert(player.role == -1)
		else:
			assert(player.role >= GameEnums.DefenderRole.PAPA)
			assert(player.role <= GameEnums.DefenderRole.BESTIA)
			assert(player.passive == -1)

	var restored: Dictionary = contracts.from_json(contracts.to_json(assignments))
	assert(restored == assignments)
	assert(RoleContractsData.new(false).assign_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6], rng).is_empty())
	print("role_contracts_test: PASS")
	quit(0)
