extends SceneTree

const Bridge = preload("res://scripts/network/lobby_game_state_bridge.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var complete_roster: Array[Dictionary] = []
	for peer_id in range(1, 7):
		complete_roster.append({"id": peer_id, "name": "Player %d" % peer_id, "ready": true})
	var valid_result: Dictionary = Bridge.build_game_state_roster(complete_roster)
	assert(valid_result["valid"])
	assert(valid_result["roster"].size() == 6)
	assert(valid_result["roster"][0] == {"peer_id": 1, "ready": true})

	var short_roster := complete_roster.slice(0, 5)
	assert(not Bridge.build_game_state_roster(short_roster)["valid"])

	var duplicate_roster := complete_roster.duplicate(true)
	duplicate_roster[5]["id"] = duplicate_roster[4]["id"]
	assert(not Bridge.build_game_state_roster(duplicate_roster)["valid"])

	var not_ready_roster := complete_roster.duplicate(true)
	not_ready_roster[2]["ready"] = false
	assert(not Bridge.build_game_state_roster(not_ready_roster)["valid"])
	print("lobby_game_state_bridge_test: PASS")
	quit(0)
