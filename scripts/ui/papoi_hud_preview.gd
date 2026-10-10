extends Control

const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const COOKING_CAPTURE_PATH := "res://docs/handoffs/GE02-hud-cooking-1280x720.png"
const RESULT_CAPTURE_PATH := "res://docs/handoffs/GE02-hud-result-1280x720.png"

func _ready() -> void:
	var papoi_theme := load("res://scenes/ui/papoi_theme.tres") as Theme
	theme = papoi_theme
	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = load("res://assets/maps/Mapa Base.jpeg")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var hud := HUD_SCENE.instantiate() as PapoiHUD
	add_child(hud)
	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.POT_COOKING,
		"round_number": 3,
		"round_time_remaining": 300.0,
		"phase_time_remaining": 18.0,
		"scores": {"TEAM_A": 2, "TEAM_B": 1},
		"papa_state": GameEnums.PapaState.BEING_COOKED,
		"players": [{
			"peer_id": 1,
			"role": -1,
			"passive": GameEnums.AttackerPassive.PORTA_PAPAS,
			"lives": 2,
			"cooldowns": {},
		}],
		"local_peer_id": 1,
	})
	_add_preview_badge(hud, papoi_theme)
	call_deferred("_capture_graphical_previews", hud)

func _capture_graphical_previews(hud: PapoiHUD) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if not _save_capture(COOKING_CAPTURE_PATH):
		return

	hud.apply_match_snapshot({
		"phase": GameEnums.GamePhase.ROUND_RESULT,
		"round_number": 3,
		"round_time_remaining": 0.0,
		"phase_time_remaining": 0.0,
		"scores": {"TEAM_A": 2, "TEAM_B": 1},
		"papa_state": GameEnums.PapaState.COOKED,
		"round_winner": GameEnums.TeamSide.TEAM_A,
		"round_end_reason": GameEnums.RoundEndReason.ESCAPE_SUCCESS,
	})
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_save_capture(RESULT_CAPTURE_PATH)

func _save_capture(path: String) -> bool:
	var capture := get_viewport().get_texture().get_image()
	if capture.get_size() != Vector2i(1280, 720):
		push_error("La captura debe ser 1280x720; recibido %s" % capture.get_size())
		return false
	var error := capture.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("No se pudo guardar la preview: %s" % error)
		return false
	print("GE02_HUD_PREVIEW_CAPTURE: PASS — %s" % path)
	return true

func _add_preview_badge(hud: CanvasLayer, papoi_theme: Theme) -> void:
	var badge := PanelContainer.new()
	badge.theme = papoi_theme
	badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	badge.position = Vector2(-320.0, 86.0)
	badge.z_index = 30
	var label := Label.new()
	label.text = "PREVIEW · DATOS SIMULADOS"
	badge.add_child(label)
	hud.add_child(badge)
