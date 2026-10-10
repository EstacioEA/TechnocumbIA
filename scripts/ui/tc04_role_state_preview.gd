extends Control

const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const CAPTURE_PATH := "res://docs/handoffs/evidence/tc04/tc04-role-state-1280x720.png"

var _hud: PapoiHUD
var _selection_label: Label
var _role_cases: Array[Dictionary] = []
var _selected_index := 5


func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	_build_background()
	_hud = HUD_SCENE.instantiate() as PapoiHUD
	add_child(_hud)
	_build_selector()
	_role_cases = _make_role_cases()
	_select_role(_selected_index)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F12:
		_capture_preview.call_deferred()
		get_viewport().set_input_as_handled()
		return
	if event.keycode < KEY_1 or event.keycode > KEY_6:
		return
	_select_role(event.keycode - KEY_1)
	get_viewport().set_input_as_handled()


func _build_background() -> void:
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = load("res://assets/maps/Mapa Base.jpeg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)


func _build_selector() -> void:
	var panel := PanelContainer.new()
	panel.theme = theme
	panel.position = Vector2(24.0, 88.0)
	panel.custom_minimum_size = Vector2(440.0, 0.0)
	panel.z_index = 30
	_hud.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var title := Label.new()
	title.text = "TC04 · PREVIEW SIMULADA"
	title.add_theme_font_size_override("font_size", 18)
	content.add_child(title)

	_selection_label = Label.new()
	_selection_label.text = "Selecciona un rol · F12 guarda la vista"
	_selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_selection_label)

	var roles := GridContainer.new()
	roles.columns = 3
	roles.add_theme_constant_override("h_separation", 6)
	roles.add_theme_constant_override("v_separation", 6)
	content.add_child(roles)

	var labels := ["Tanque", "Cazador", "Porta Papas", "Papa", "Trolazzo", "Bestia"]
	for index in labels.size():
		var button := Button.new()
		button.text = "%d · %s" % [index + 1, labels[index]]
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_select_role.bind(index))
		roles.add_child(button)


func _make_role_cases() -> Array[Dictionary]:
	return [
		{"name": "Tanque", "role": -1, "passive": GameEnums.AttackerPassive.TANQUE, "lives": 3, "cooldowns": {}},
		{"name": "Cazador", "role": -1, "passive": GameEnums.AttackerPassive.CAZADOR, "lives": 3, "cooldowns": {}},
		{"name": "Porta Papas", "role": -1, "passive": GameEnums.AttackerPassive.PORTA_PAPAS, "lives": 2, "cooldowns": {"sprint": 1.5}},
		{"name": "Papa", "role": GameEnums.DefenderRole.PAPA, "passive": -1, "lives": 0, "cooldowns": {}},
		{"name": "Trolazzo", "role": GameEnums.DefenderRole.TROLAZZO, "passive": -1, "lives": 0, "cooldowns": {"trap": 8.0}},
		{"name": "Bestia", "role": GameEnums.DefenderRole.BESTIA, "passive": -1, "lives": 0, "cooldowns": {"beast_basic": 2.5, "beast_special": 0.0}},
	]


func _select_role(index: int) -> void:
	if index < 0 or index >= _role_cases.size():
		return
	_selected_index = index
	var role_case: Dictionary = _role_cases[index]
	_selection_label.text = "%d/6 · %s · ejemplo local; no representa una partida real" % [index + 1, role_case.name]
	_hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.ACTIVE,
		"round_number": 1,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 120.0,
		"scores": {"TEAM_A": 0, "TEAM_B": 0},
		"papa_state": GameEnums.PapaState.FREE,
		"local_peer_id": 40 + index,
		"players": [{
			"peer_id": 40 + index,
			"role": role_case.role,
			"passive": role_case.passive,
			"lives": role_case.lives,
			"cooldowns": role_case.cooldowns.duplicate(true),
		}],
	})


func _capture_preview() -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var directory := ProjectSettings.globalize_path("res://docs/handoffs/evidence/tc04")
	DirAccess.make_dir_recursive_absolute(directory)
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(CAPTURE_PATH))
	if error != OK:
		push_error("TC04_PREVIEW: no se pudo guardar la captura (%s)." % error)
		return
	print("TC04_PREVIEW_CAPTURE: %s (%s)" % [CAPTURE_PATH, image.get_size()])
