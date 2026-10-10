extends SceneTree

const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const EVIDENCE_ROOT := "res://docs/handoffs/evidence/gint"

var _failures: Array[String] = []
var _cases: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("GINT_HUD_1920_PREVIEW_TEST requiere renderer gráfico para las capturas.")
		quit(2)
		return
	_cases = _build_cases()
	var resolutions := [Vector2i(1920, 1080)]
	for resolution in resolutions:
		root.size = resolution
		await process_frame
		await process_frame
		await _capture_resolution(resolution)
	if _failures.is_empty():
		print("GINT_HUD_1920_PREVIEW_TEST: PASS — 5 estados × 1 resolución (1920×1080)")
		quit(0)
		return
	for failure in _failures:
		push_error("GINT_HUD_1920_PREVIEW_TEST: %s" % failure)
	quit(1)

func _capture_resolution(resolution: Vector2i) -> void:
	var resolution_name := "%dx%d" % [resolution.x, resolution.y]
	var evidence_dir := ProjectSettings.globalize_path(EVIDENCE_ROOT.path_join(resolution_name))
	var mkdir_error := DirAccess.make_dir_recursive_absolute(evidence_dir)
	_check(mkdir_error == OK or mkdir_error == ERR_ALREADY_EXISTS, "evidence directory exists for %s" % resolution_name)

	var preview_root := Control.new()
	preview_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_root.theme = load("res://scenes/ui/papoi_theme.tres")
	root.add_child(preview_root)
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = load("res://assets/maps/Mapa Base.jpeg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_root.add_child(background)
	var hud := HUD_SCENE.instantiate() as PapoiHUD
	preview_root.add_child(hud)
	var badge := _make_preview_badge(hud, preview_root.theme)
	await process_frame

	for preview_case in _cases:
		hud.apply_match_snapshot(preview_case.snapshot)
		badge.text = "PREVIEW · SIMULADO · %s" % preview_case.label
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		_check_visible_labels_fit(hud, resolution, preview_case.label)
		var image := root.get_texture().get_image()
		_check(image != null and image.get_size() == resolution, "%s capture size %s" % [preview_case.label, resolution_name])
		if image == null or image.is_empty():
			continue
		var filename := "%s_%s.png" % [preview_case.key, resolution_name]
		var output_path := evidence_dir.path_join(filename)
		var save_error := image.save_png(output_path)
		_check(save_error == OK, "%s capture saved at %s" % [preview_case.label, resolution_name])

	preview_root.queue_free()
	await process_frame

func _check_visible_labels_fit(hud: PapoiHUD, resolution: Vector2i, case_label: String) -> void:
	var labels: Array[Label] = [
		hud.phase_label,
		hud.phase_tag_label,
		hud.objective_label,
		hud.timer_label,
		hud.round_label,
		hud.score_label,
		hud.lives_label,
		hud.role_label,
		hud.passive_label,
		hud.cooldown_label,
		hud.cooldown_status_label,
		hud.status_label,
	]
	if hud.result_card.visible:
		labels.append_array([
			hud.result_header_label,
			hud.result_label,
			hud.result_detail_label,
			hud.result_score_label,
		])
	for label in labels:
		if label == null or not label.is_visible_in_tree():
			continue
		var rect := label.get_global_rect()
		_check(
			rect.position.x >= -1.0 and rect.position.y >= -1.0
			and rect.end.x <= float(resolution.x) + 1.0
			and rect.end.y <= float(resolution.y) + 1.0,
			"%s label stays inside %s" % [case_label, resolution]
		)
		if label.autowrap_mode == TextServer.AUTOWRAP_OFF:
			_check(
				label.get_combined_minimum_size().x <= label.size.x + 1.0,
				"%s label has enough width at %s: %s" % [case_label, resolution, label.text]
			)

func _make_preview_badge(hud: CanvasLayer, papoi_theme: Theme) -> Label:
	var panel := PanelContainer.new()
	panel.theme = papoi_theme
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-390.0, 86.0)
	panel.custom_minimum_size.x = 366.0
	panel.z_index = 30
	hud.add_child(panel)
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return label

func _build_cases() -> Array[Dictionary]:
	var common_player := [{
		"peer_id": 1,
		"role": -1,
		"passive": GameEnums.AttackerPassive.PORTA_PAPAS,
		"lives": 2,
		"cooldowns": {"sprint": 1.5, "dash": 0.0},
	}]
	var common := {
		"round_number": 3,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 120.0,
		"scores": {"TEAM_A": 2, "TEAM_B": 1},
		"players": common_player,
		"local_peer_id": 1,
	}
	var result: Array[Dictionary] = []
	result.append(_phase_case("active", "ACTIVE", GameEnums.GamePhase.ACTIVE, GameEnums.PapaState.FREE, common))
	var cooking := common.duplicate(true)
	cooking["phase_time_remaining"] = 18.0
	result.append(_phase_case("pot_cooking", "POT_COOKING", GameEnums.GamePhase.POT_COOKING, GameEnums.PapaState.BEING_COOKED, cooking))
	result.append(_phase_case("escape", "ESCAPE", GameEnums.GamePhase.ESCAPE, GameEnums.PapaState.COOKED, common))
	var round_result: Dictionary = common.duplicate(true)
	round_result.merge({
		"phase": GameEnums.GamePhase.ROUND_RESULT,
		"round_time_remaining": 0.0,
		"phase_time_remaining": 0.0,
		"round_winner": GameEnums.TeamSide.TEAM_A,
		"round_end_reason": GameEnums.RoundEndReason.ESCAPE_SUCCESS,
	}, true)
	result.append({"key": "round_result", "label": "ROUND_RESULT", "snapshot": round_result})
	var match_result: Dictionary = common.duplicate(true)
	match_result.merge({
		"phase": GameEnums.GamePhase.MATCH_RESULT,
		"round_number": 5,
		"round_time_remaining": 0.0,
		"phase_time_remaining": 0.0,
		"scores": {"TEAM_A": 2, "TEAM_B": 3},
		"match_winner": GameEnums.TeamSide.TEAM_B,
		"round_end_reason": -1,
	}, true)
	result.append({"key": "match_result", "label": "MATCH_RESULT", "snapshot": match_result})
	return result

func _phase_case(key: String, label: String, phase: int, papa_state: int, source: Dictionary) -> Dictionary:
	var snapshot: Dictionary = source.duplicate(true)
	snapshot["phase"] = phase
	snapshot["papa_state"] = papa_state
	return {"key": key, "label": label, "snapshot": snapshot}

func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
