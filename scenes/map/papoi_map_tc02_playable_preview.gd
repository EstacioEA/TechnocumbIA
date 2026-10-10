extends Node2D

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const BOUNDARY_OVERLAY := preload("res://scenes/map/papoi_map_tc02_boundary_overlay.gd")

func _ready() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		push_error("TC02 playable preview could not instantiate PapoiMap")
		return
	add_child(map)
	map.set_debug_overlay_visible(true)
	var boundary_overlay := BOUNDARY_OVERLAY.new()
	add_child(boundary_overlay)

	var player := PLAYER_SCENE.instantiate() as PapoiPlayerController
	if player == null:
		push_error("TC02 playable preview could not instantiate player")
		return
	player.name = "TC02LocalPlayer"
	player.position = PapoiMap.ATTACKER_SPAWNS[0]
	player.enforce_playable_routes = true
	player.playable_routes_provider = map
	add_child(player)

	var camera := player.get_node_or_null("LocalCamera") as Camera2D
	if camera:
		camera.enabled = false
