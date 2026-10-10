extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var _failures: Array[String] = []

func _init() -> void:
	var local_player := PLAYER_SCENE.instantiate() as CharacterBody2D
	var remote_player := PLAYER_SCENE.instantiate() as CharacterBody2D
	if local_player == null or remote_player == null:
		_fail("player scene did not instantiate twice")
		_finish()
		return

	remote_player.name = "RemotePlayer"
	remote_player.local_control_enabled = false
	root.add_child(local_player)
	root.add_child(remote_player)
	await process_frame

	var local_camera := local_player.get_node("LocalCamera") as Camera2D
	var remote_camera := remote_player.get_node("LocalCamera") as Camera2D
	var local_overlay := local_player.get_node("VisionOverlay") as CanvasLayer
	var remote_overlay := remote_player.get_node("VisionOverlay") as CanvasLayer
	_assert_local_camera(local_camera)
	_assert_remote_camera(remote_camera)
	_assert_local_overlay(local_overlay)
	_assert_remote_overlay(remote_overlay)
	_assert_hud_layer_is_above_overlay(local_overlay)
	_finish()

func _assert_local_camera(camera: Camera2D) -> void:
	if not camera.enabled:
		_fail("local camera must be enabled")
	if camera.follow_target == null:
		_fail("local camera must follow its player")
	if camera.limit_right <= camera.limit_left or camera.limit_bottom <= camera.limit_top:
		_fail("local camera map limits are invalid")

func _assert_remote_camera(camera: Camera2D) -> void:
	if camera.enabled:
		_fail("remote camera must be disabled")

func _assert_local_overlay(overlay: CanvasLayer) -> void:
	if overlay.layer != 20:
		_fail("local vision overlay must use layer 20")
	var rect := overlay.get_node("OverlayRect") as ColorRect
	var material := rect.material as ShaderMaterial
	if material == null:
		_fail("vision overlay must use a shader material")
		return
	var radius: float = material.get_shader_parameter("vision_radius")
	if not is_equal_approx(radius, 0.4):
		_fail("vision radius must represent 80 percent of the viewport")
	var shader_code := material.shader.code
	if not shader_code.contains("outside_visibility"):
		_fail("vision shader must darken the area outside the visible circle")
	if shader_code.contains("COLOR.a * edge"):
		_fail("vision shader must not darken the visible circle")

func _assert_remote_overlay(overlay: CanvasLayer) -> void:
	if overlay.layer != -1:
		_fail("remote vision overlay must be disabled")

func _assert_hud_layer_is_above_overlay(overlay: CanvasLayer) -> void:
	var hud := CanvasLayer.new()
	hud.layer = 30
	root.add_child(hud)
	if hud.layer <= overlay.layer:
		_fail("HUD layer must be above the vision overlay")
	hud.queue_free()

func _fail(message: String) -> void:
	_failures.append(message)

func _finish() -> void:
	if _failures.is_empty():
		print("V04_CAMERA_VISION_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("V04_CAMERA_VISION_TEST: %s" % failure)
	quit(1)
