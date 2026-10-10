extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const VISUAL_SCRIPT = preload("res://scripts/player/player_visual.gd")

var _failures: Array[String] = []

func _init() -> void:
	var attacker := PLAYER_SCENE.instantiate() as CharacterBody2D
	var defender := PLAYER_SCENE.instantiate() as CharacterBody2D
	if attacker == null or defender == null:
		_fail("player scene did not instantiate twice")
		_finish()
		return

	root.add_child(attacker)
	root.add_child(defender)
	await process_frame

	var attacker_visual: Node2D = attacker.get_node("PlayerVisual")
	var defender_visual: Node2D = defender.get_node("PlayerVisual")
	defender_visual.set("team", VISUAL_SCRIPT.Team.DEFENDERS)
	defender_visual.queue_redraw()

	if attacker_visual == null or defender_visual == null:
		_fail("isolated player visual component is missing")
	else:
		if attacker_visual.get("team") == defender_visual.get("team"):
			_fail("teams must use distinct visual variants")
		if attacker_visual.get("silhouette_radius") <= 0.0 or defender_visual.get("silhouette_radius") <= 0.0:
			_fail("silhouette radius must be positive")

	var collision := attacker.get_node("CollisionShape2D") as CollisionShape2D
	var shape := collision.shape as CircleShape2D
	if shape == null or not is_equal_approx(shape.radius, 18.0):
		_fail("visual integration must preserve the player collider")

	_finish()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("GV01_CHARACTERS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GV01_CHARACTERS_TEST: %s" % failure)
	quit(1)
