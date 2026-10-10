extends SceneTree

const TowerKeyStateData = preload("res://scripts/objectives/tower_key_state.gd")

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var state := TowerKeyStateData.new(true)
	assert(state.configure_round([1, 2, 3]))
	assert(state.spawn_at(Vector2(0.0, 0.0)))
	assert(state.get_snapshot()["key_visible"])
	assert(not state.request_collect(1, Vector2(0.0, 0.0), 1, 40.0))
	assert(state.request_collect(2, Vector2(10.0, 0.0), -1, 40.0))
	assert(not state.spawn_at(Vector2(10.0, 0.0)))
	assert(state.request_open_tower(2, Vector2(920.0, 270.0), Vector2(920.0, 270.0), 96.0))
	assert(state.get_snapshot()["tower_open"])
	assert(not state.drop_at(Vector2(20.0, 0.0), 2))

	assert(state.configure_round([1, 2, 3]))
	assert(state.spawn_at(Vector2(10.0, 10.0)))
	assert(state.request_collect(1, Vector2(10.0, 10.0), -1, 40.0))
	assert(state.drop_at(Vector2(50.0, 60.0), 1))
	assert(state.get_snapshot()["key_visible"])
	assert(state.get_snapshot()["key_position"] == Vector2(50.0, 60.0))

	var client_state := TowerKeyStateData.new(false)
	assert(not client_state.configure_round([1, 2, 3]))
	print("tower_key_state_test: PASS")
	quit(0)
