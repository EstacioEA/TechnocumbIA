extends Node2D

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HUD_SCENE := preload("res://scenes/ui/papoi_hud.tscn")

var _overlay: CanvasLayer

func _ready() -> void:
	var map := MAP_SCENE.instantiate()
	add_child(map)

	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.name = "LocalPreviewPlayer"
	player.position = Vector2(640.0, 360.0)
	add_child(player)
	var camera := player.get_node("LocalCamera") as Camera2D
	camera.map_bounds = Rect2(0.0, 0.0, 1280.0, 720.0)
	camera.camera_zoom = Vector2.ONE
	_overlay = player.get_node("VisionOverlay") as CanvasLayer

	var hud := HUD_SCENE.instantiate() as PapoiHUD
	hud.layer = 30
	add_child(hud)
	await get_tree().process_frame
	hud.apply_snapshot({
		"phase": "ACTIVE",
		"round": 1,
		"round_time_remaining": 420.0,
		"score": {"attackers": 1, "defenders": 0},
		"objective_text": "Lleva a Papa a la olla en Torre",
	})
	hud.set_player_context(3, "CAZADOR", "Rastreo", {"embestida": 0.0, "grito": 4.0})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_V:
		_overlay.layer = -1 if _overlay.layer > 0 else 20
