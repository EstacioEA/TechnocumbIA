extends SceneTree

const Preview = preload("res://tests/ui/gm01_role_icons_preview.gd")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var preview := Preview.new()
	root.add_child(preview)
	await process_frame
	_check(preview.ROLE_ICONS.size() == 6, "preview contains six role/passive entries")
	for icon_data in preview.ROLE_ICONS:
		var texture := load(icon_data.path) as Texture2D
		_check(texture != null, "%s loads as a texture" % icon_data.name)
		_check(texture.get_size() == Vector2(64.0, 64.0), "%s uses HUD icon size" % icon_data.name)
	_check(preview.get_child_count() >= 2, "preview contains title and icon grid")

	if _failures.is_empty():
		print("GM01_ROLE_ICONS_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GM01_ROLE_ICONS_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
