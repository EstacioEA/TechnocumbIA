extends SceneTree

const PREVIEW_SCENE := preload("res://tests/ui/gv03_six_players_preview.tscn")
const PLAYER_NAMES := [
	&"AttackerOne",
	&"AttackerTwo",
	&"AttackerThree",
	&"DefenderOne",
	&"DefenderTwo",
	&"DefenderThree",
]

var _failures: Array[String] = []

func _init() -> void:
	var preview := PREVIEW_SCENE.instantiate()
	root.add_child(preview)
	await process_frame
	await process_frame

	var local_markers := 0
	var attacker_count := 0
	var defender_count := 0
	for player_name in PLAYER_NAMES:
		var player := preview.get_node_or_null(NodePath(player_name)) as CharacterBody2D
		if player == null:
			_fail("missing player instance: %s" % player_name)
			continue
		var collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision == null or collision.shape == null:
			_fail("%s lost its collision shape" % player_name)
		var visual := player.get_node_or_null("PlayerVisual") as Node2D
		if visual == null:
			_fail("%s lost its visual component" % player_name)
			continue
		var team: int = visual.get("team")
		if team == 0:
			attacker_count += 1
		elif team == 1:
			defender_count += 1
		else:
			_fail("%s has an unknown team" % player_name)
		if visual.get("show_local_marker") == true:
			local_markers += 1
		if player.get("local_control_enabled") and player_name != &"AttackerOne":
			_fail("only AttackerOne may be local")

	if attacker_count != 3 or defender_count != 3:
		_fail("expected three attackers and three defenders")
	if local_markers != 1:
		_fail("expected exactly one local-player marker")

	var local_overlay := preview.get_node("AttackerOne/VisionOverlay") as CanvasLayer
	if local_overlay == null or local_overlay.layer != 20:
		_fail("active vision overlay is missing")
	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GV03_SIX_PLAYERS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GV03_SIX_PLAYERS_TEST: %s" % failure)
	quit(1)
