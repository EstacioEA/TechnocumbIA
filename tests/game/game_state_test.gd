extends SceneTree

const GameStateNode = preload("res://scripts/game/game_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var game := GameStateNode.new()
	root.add_child(game)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	assert(game.configure_lobby(roster))
	assert(game.start_match())
	game._process(4.0)
	assert(game.get_snapshot().phase == GameEnums.GamePhase.ACTIVE)
	var first_attack := game.get_snapshot().attacking_team
	assert(not game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS))
	assert(game.get_snapshot().scores[first_attack] == 0)
	assert(game.capture_papa())
	assert(game.begin_pot_cooking())
	game._process(GameStateNode.POT_COOKING_DURATION_SECONDS + 1.0)
	assert(game.get_snapshot().phase == GameEnums.GamePhase.ESCAPE)
	assert(game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS))
	assert(game.get_snapshot().scores[first_attack] == 1)
	for expected_round in range(2, 5):
		assert(game.start_next_round())
		game._process(4.0)
		var snapshot := game.get_snapshot()
		assert(snapshot.round_number == expected_round)
		var expected_attack := 1 - first_attack if expected_round % 2 == 0 else first_attack
		assert(snapshot.attacking_team == expected_attack)
		assert(game.resolve_round(1 - snapshot.attacking_team, GameEnums.RoundEndReason.ATTACKERS_ELIMINATED))
	assert(game.get_snapshot().phase == GameEnums.GamePhase.MATCH_RESULT)
	assert(game.get_snapshot().match_winner == first_attack)
	assert(not game.start_next_round())
	print("game_state_test: PASS")
	quit(0)
