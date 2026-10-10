extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var local_player := PLAYER_SCENE.instantiate() as CharacterBody2D
	var remote_player := PLAYER_SCENE.instantiate() as CharacterBody2D
	if local_player == null or remote_player == null:
		_fail("player scene did not instantiate")
		_finish()
		return

	remote_player.local_control_enabled = false
	root.add_child(local_player)
	root.add_child(remote_player)
	await process_frame

	var local_visual := local_player.get_node("PlayerVisual") as Node2D
	var remote_visual := remote_player.get_node("PlayerVisual") as Node2D
	if local_visual == null or remote_visual == null:
		_fail("player visual component is missing")
		_finish()
		return

	local_player.velocity = Vector2.UP
	await process_frame
	if not is_equal_approx(local_visual.rotation, -PI / 2.0):
		_fail("visual orientation must follow movement direction")
	if local_visual.get("show_local_marker") != true:
		_fail("local player marker is missing")
	if remote_visual.get("show_local_marker") != false:
		_fail("remote player must use the remote marker")

	var collision := local_player.get_node("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		_fail("orientation integration must preserve collision")
	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GV02_ORIENTATION_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GV02_ORIENTATION_TEST: %s" % failure)
	quit(1)
