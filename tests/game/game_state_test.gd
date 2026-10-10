extends SceneTree

const GameStateNode = preload("res://scripts/game/game_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	_test_json_round_trip()
	var game := GameStateNode.new()
	root.add_child(game)
	var roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		roster.append({"peer_id": peer_id, "ready": true})
	assert(game.configure_lobby(roster))
	assert(game.start_match())
	game._process(4.0)
	assert(game.get_snapshot().phase == GameEnums.GamePhase.ACTIVE)
	var first_attack: int = game.get_snapshot().attacking_team
	assert(not game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS))
	var first_attack_score_key := MatchStateData.team_score_key(first_attack)
	assert(game.get_snapshot().scores[first_attack_score_key] == 0)
	assert(game.capture_papa())
	assert(game.begin_pot_cooking())
	game._process(GameStateNode.POT_COOKING_DURATION_SECONDS + 1.0)
	assert(game.get_snapshot().phase == GameEnums.GamePhase.ESCAPE)
	assert(game.resolve_round(first_attack, GameEnums.RoundEndReason.ESCAPE_SUCCESS))
	assert(game.get_snapshot().scores[first_attack_score_key] == 1)
	for expected_round in range(2, 5):
		assert(game.start_next_round())
		game._process(4.0)
		var snapshot := game.get_snapshot()
		assert(snapshot.round_number == expected_round)
		var expected_attack: int = 1 - first_attack if expected_round % 2 == 0 else first_attack
		assert(snapshot.attacking_team == expected_attack)
		assert(game.resolve_round(1 - snapshot.attacking_team, GameEnums.RoundEndReason.ATTACKERS_ELIMINATED))
	assert(game.get_snapshot().phase == GameEnums.GamePhase.MATCH_RESULT)
	assert(game.get_snapshot().match_winner == first_attack)
	assert(not game.start_next_round())
	print("game_state_test: PASS")
	quit(0)


func _test_json_round_trip() -> void:
	var original := MatchStateData.new()
	original.revision = 8
	original.phase = GameEnums.GamePhase.ESCAPE
	original.players.append({"peer_id": 11, "ready": true, "team": GameEnums.TeamSide.TEAM_A})
	original.scores = {"TEAM_A": 2, "TEAM_B": 1}
	original.round_number = 4
	original.attacking_team = GameEnums.TeamSide.TEAM_B
	original.round_time_remaining = 96.5
	original.papa_state = GameEnums.PapaState.COOKED
	var restored := MatchStateData.from_json(original.to_json())
	assert(restored != null)
	assert(restored.to_dictionary() == original.to_dictionary())
	var invalid_snapshot := original.to_dictionary()
	invalid_snapshot.phase = 99
	assert(MatchStateData.from_dictionary(invalid_snapshot) == null)
