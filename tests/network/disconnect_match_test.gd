extends SceneTree

const LobbyScene = preload("res://scenes/lobby/lobby.tscn")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MATCH_TIMEOUT := 35.0

var _lobby: Control
var _manager: Node
var _bridge: Node
var _game_state: Node
var _role := ""
var _player_name := ""
var _marker_dir := ""
var _host_ready := false
var _client_ready_requested := false
var _start_scheduled := false
var _disconnect_sent := false
var _host_disconnect_notice_seen := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 4:
		_fail("Usage: disconnect_match_test.gd -- <host|client> <port> <name> <marker_dir>")
		return
	_role = str(args[0])
	var port_text := str(args[1])
	_player_name = str(args[2])
	_marker_dir = str(args[3])
	if not port_text.is_valid_int() or _role not in ["host", "client"]:
		_fail("Invalid test arguments.")
		return
	if not DirAccess.dir_exists_absolute(_marker_dir):
		if DirAccess.make_dir_recursive_absolute(_marker_dir) != OK:
			_fail("Could not create marker directory.")
			return

	_lobby = LobbyScene.instantiate()
	root.add_child(_lobby)
	await process_frame
	_manager = _lobby.get_node("NetworkManager")
	_game_state = _lobby.get_node("GameState")
	_bridge = _lobby.get_node("NetworkGameBridge")
	_manager.lobby_updated.connect(_on_lobby_updated)
	_manager.lobby_start.connect(_on_lobby_start)
	_manager.peer_left.connect(_on_peer_left_observed)
	_manager.status_changed.connect(_on_status_changed)
	_manager.lobby_rejected.connect(_on_lobby_rejected)
	_game_state.phase_changed.connect(_on_game_phase_changed)
	_bridge.snapshot_updated.connect(_on_snapshot_updated)
	_bridge.match_invalidated.connect(_on_match_invalidated)

	var port := port_text.to_int()
	if _role == "host":
		if _manager.host_game(port) != OK:
			_fail("Could not create ENet host on port %d." % port)
			return
		_mark("host-ready")
		print("DISCONNECT_HOST_READY port=%d" % port)
	else:
		if _manager.join_game("127.0.0.1", port) != OK:
			_fail("Could not start client connection for %s." % _player_name)
			return
		print("DISCONNECT_CLIENT_CONNECTING name=%s" % _player_name)

	create_timer(MATCH_TIMEOUT).timeout.connect(func() -> void: _fail("Timed out in role %s (%s)." % [_player_name, _role]))


func _on_lobby_updated(snapshot: Array[Dictionary]) -> void:
	if snapshot.size() != 6:
		return
	if _role == "host":
		if not _host_ready:
			_host_ready = _manager.set_local_ready(true)
			if not _host_ready:
				_fail("Host could not set ready.")
				return
			_mark("host-roster-six")
		if _all_ready() and not _start_scheduled:
			_start_scheduled = true
			call_deferred("_start_match")
		return

	if _client_ready_requested or not _snapshot_has_local_player(snapshot):
		return
	_client_ready_requested = true
	if not _manager.set_local_ready(true):
		_fail("Client could not set ready.")
		return
	_mark("%s-ready-requested" % _player_name)


func _start_match() -> void:
	if not _all_ready() or not _manager.request_start_match():
		_fail("Host could not start with all six players ready.")


func _on_lobby_start() -> void:
	if _role == "host":
		if _game_state.get_snapshot().phase != GameEnums.GamePhase.COUNTDOWN:
			_fail("Runtime bridge did not initialize GameState from lobby_start.")
			return
		_mark("host-lobby-start")
		print("DISCONNECT_HOST_GAMESTATE_STARTED")
	else:
		_mark("%s-lobby-start" % _player_name)
		print("DISCONNECT_CLIENT_MATCH_STARTED name=%s" % _player_name)


func _on_game_phase_changed(_previous_phase: int, current_phase: int) -> void:
	if _role == "host" and current_phase == GameEnums.GamePhase.ACTIVE:
		_mark("host-match-active")
		print("DISCONNECT_MATCH_ACTIVE")


func _on_snapshot_updated(snapshot: Dictionary) -> void:
	if _role != "client":
		return
	var phase := int(snapshot.get("phase", -1))
	if _player_name == "client1" and phase == GameEnums.GamePhase.ACTIVE and not _disconnect_sent:
		_disconnect_sent = true
		_mark("client1-match-active")
		call_deferred("_disconnect_after_match_start")
		return
	if _player_name == "client1" or not _is_disconnect_result(snapshot):
		return
	_mark("%s-match-invalidated" % _player_name)
	print("DISCONNECT_CLIENT_RESULT_RECEIVED name=%s" % _player_name)
	call_deferred("_finish_client_after_result")


func _disconnect_after_match_start() -> void:
	await create_timer(2.5).timeout
	_manager.close_session()
	_mark("client1-disconnected-during-match")
	print("DISCONNECT_CLIENT_LEFT_MATCH")
	quit(0)


func _finish_client_after_result() -> void:
	await create_timer(0.25).timeout
	quit(0)


func _on_peer_left_observed(peer_id: int) -> void:
	if _role == "host" and peer_id > 1:
		_mark("host-peer-left-observed")


func _on_status_changed(message: String) -> void:
	if not message.begins_with("Partida invalidada:"):
		return
	var status_label: Label = _lobby.get("_status_label")
	if not status_label.text.contains("Partida invalidada"):
		_fail("Disconnection notice did not remain visible in the lobby UI.")
		return
	if _role == "host":
		_host_disconnect_notice_seen = true
		_mark("host-disconnect-message-visible")
	elif _player_name != "client1" and _is_disconnect_result(_game_state.get_snapshot()):
		_mark("%s-disconnect-message-visible" % _player_name)


func _on_lobby_rejected(reason: String) -> void:
	if _role == "client" and _player_name != "latejoin" and _is_disconnect_result(_game_state.get_snapshot()):
		return
	if _role != "client" or _player_name != "latejoin":
		_fail("Unexpected lobby rejection for %s: %s" % [_player_name, reason])
		return
	var status_label: Label = _lobby.get("_status_label")
	if not reason.contains("ya inició") or not status_label.text.contains(reason):
		_fail("Late-join rejection was not clear in the UI: %s" % status_label.text)
		return
	_mark("latejoin-rejected")
	quit(0)


func _on_match_invalidated(snapshot: Dictionary) -> void:
	if _role != "host" or not _is_disconnect_result(snapshot):
		_fail("Runtime bridge emitted an invalid disconnect result.")
		return
	_mark("host-match-invalidated")
	print("DISCONNECT_HOST_MATCH_INVALIDATED")
	call_deferred("_wait_for_connected_clients")


func _wait_for_connected_clients() -> void:
	var client_markers := ["client2-match-invalidated.ok", "client3-match-invalidated.ok", "client4-match-invalidated.ok", "client5-match-invalidated.ok"]
	var deadline := Time.get_ticks_msec() + 8000
	while Time.get_ticks_msec() < deadline:
		var all_received := true
		for marker_name: String in client_markers:
			if not FileAccess.file_exists(_marker_dir.path_join(marker_name)):
				all_received = false
				break
		if all_received:
			if not _host_disconnect_notice_seen:
				_fail("Host did not show the disconnection result in the lobby UI.")
				return
			_mark("host-connected-clients-confirmed")
			quit(0)
			return
		await create_timer(0.1).timeout
	_fail("Connected clients did not confirm the host result snapshot.")


func _is_disconnect_result(snapshot: Dictionary) -> bool:
	var scores: Dictionary = snapshot.get("scores", {})
	return snapshot.get("phase") == GameEnums.GamePhase.MATCH_RESULT \
		and snapshot.get("round_end_reason") == GameEnums.RoundEndReason.DISCONNECT \
		and snapshot.get("round_winner") == -1 \
		and snapshot.get("match_winner") == -1 \
		and scores.get("TEAM_A") == 0 and scores.get("TEAM_B") == 0


func _snapshot_has_local_player(snapshot: Array[Dictionary]) -> bool:
	var peer: MultiplayerPeer = _manager.multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return false
	var local_id: int = _manager.multiplayer.get_unique_id()
	for entry: Dictionary in snapshot:
		if entry.get("id") == local_id:
			return true
	return false


func _all_ready() -> bool:
	if _manager.players.size() != 6:
		return false
	for player: Dictionary in _manager.players.values():
		if not bool(player.get("ready", false)):
			return false
	return true


func _mark(marker_name: String) -> void:
	var marker := FileAccess.open(_marker_dir.path_join("%s.ok" % marker_name), FileAccess.WRITE)
	if marker == null:
		_fail("Could not write marker %s." % marker_name)
		return
	marker.store_string("PASS\n")
	marker.close()


func _fail(message: String) -> void:
	printerr("DISCONNECT_TEST_FAIL role=%s name=%s: %s" % [_role, _player_name, message])
	quit(1)
