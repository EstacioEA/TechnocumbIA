extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []
var _intent_count := 0

func _init() -> void:
	var local_player := PLAYER_SCENE.instantiate() as PapoiPlayerController
	var remote_player := PLAYER_SCENE.instantiate() as PapoiPlayerController
	if local_player == null or remote_player == null:
		_fail("player scene could not be instantiated twice")
		_finish()
		return

	local_player.name = "LocalPlayer"
	remote_player.name = "RemotePlayer"
	remote_player.local_control_enabled = false
	remote_player.allow_local_prediction = false
	root.add_child(local_player)
	root.add_child(remote_player)
	local_player.movement_intent.connect(_on_local_movement_intent)
	await process_frame

	var local_start := local_player.global_position
	var remote_start := remote_player.global_position
	Input.action_press(&"move_right")
	await physics_frame
	await physics_frame
	Input.action_release(&"move_right")

	if _intent_count == 0:
		_fail("local player did not emit movement intent")
	if local_player.global_position == local_start:
		_fail("local player did not process local input")
	if remote_player.global_position != remote_start:
		_fail("remote player moved from local input")

	remote_player.apply_authoritative_velocity(Vector2.RIGHT * remote_player.move_speed)
	await physics_frame
	if remote_player.global_position == remote_start:
		_fail("remote player did not accept host-applied velocity")

	_finish()

func _on_local_movement_intent(_direction: Vector2) -> void:
	_intent_count += 1

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("V05_PLAYER_SMOKE_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("V05_PLAYER_SMOKE_TEST: %s" % failure)
	quit(1)
