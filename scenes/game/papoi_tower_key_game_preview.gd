extends Node

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")

var _game: PapoiGameSession

func _ready() -> void:
	var offline_peer := OfflineMultiplayerPeer.new()
	multiplayer.multiplayer_peer = offline_peer

	_game = GAME_SCENE.instantiate() as PapoiGameSession
	if _game == null:
		push_error("Tower key game preview could not instantiate PapoiGameSession")
		return
	add_child(_game)
	_game.enable_local_preview_mode()
	if not _game.start_from_lobby_roster([
		{"peer_id": 1, "ready": true},
		{"peer_id": 2, "ready": true},
		{"peer_id": 3, "ready": true},
		{"peer_id": 4, "ready": true},
		{"peer_id": 5, "ready": true},
		{"peer_id": 6, "ready": true},
	]):
		push_error("Tower key game preview could not start the integrated match")
		return
	call_deferred("_show_key_in_active_round")


func _show_key_in_active_round() -> void:
	await get_tree().create_timer(4.0).timeout
	if _game == null or not is_instance_valid(_game):
		return
	var key_state: Variant = _game.get("_tower_key_state")
	var map := _game.get_node_or_null("Map") as PapoiMap
	if key_state == null or map == null:
		return
	if key_state.spawn_at(map.to_global(map.TOWER_KEY_SPAWN)):
		_game.call("_publish_snapshot")
