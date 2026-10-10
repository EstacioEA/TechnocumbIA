extends SceneTree

const LobbyScene = preload("res://scenes/lobby/lobby.tscn")
const ProbeScript = preload("res://tests/network/disconnect_test_actor.gd")
const GameStateNode = preload("res://scripts/game/game_state.gd")
const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MATCH_TIMEOUT := 35.0

var _lobby: Control
var _manager: Node
var _probe: Node
var _game_state: Node
var _role := ""
var _player_name := ""
var _marker_dir := ""
var _host_ready := false
var _client_ready_requested := false
var _start_scheduled := false
var _disconnect_sent := false
var _acks: Dictionary = {}
var _disconnect_peer_id := -1


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
	_probe = Node.new()
	_probe.name = "DisconnectProbe"
	_probe.set_script(ProbeScript)
	_lobby.add_child(_probe)
	await process_frame
	_manager = _lobby.get_node("NetworkManager")
	_manager.lobby_updated.connect(_on_lobby_updated)
	_manager.lobby_start.connect(_on_lobby_start)
	_manager.peer_left.connect(_on_peer_left)
	_probe.snapshot_received.connect(_on_game_snapshot)
	_probe.ack_received.connect(_on_snapshot_ack)

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
			print("DISCONNECT_HOST_ROSTER_SIX")
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
		_game_state = GameStateNode.new()
		root.add_child(_game_state)
		var roster: Array[Dictionary] = []
		for peer_id: int in _manager.players:
			roster.append({"peer_id": peer_id, "ready": true})
		if not _game_state.configure_lobby(roster) or not _game_state.start_match():
			_fail("Host GameState rejected the ready roster.")
			return
		_game_state._process(GameStateNode.COUNTDOWN_DURATION_SECONDS + 0.1)
		if _game_state.get_snapshot().phase != GameEnums.GamePhase.ACTIVE:
			_fail("GameState did not enter ACTIVE.")
			return
		_mark("host-match-active")
		print("DISCONNECT_MATCH_ACTIVE")
	else:
		_mark("%s-lobby-start" % _player_name)
		print("DISCONNECT_CLIENT_MATCH_STARTED name=%s" % _player_name)
		if _player_name == "client1":
			_disconnect_after_match_start()


func _disconnect_after_match_start() -> void:
	await create_timer(1.0).timeout
	if _disconnect_sent:
		return
	_disconnect_sent = true
	_manager.close_session()
	_mark("client1-disconnected-during-match")
	print("DISCONNECT_CLIENT_LEFT_MATCH")
	quit(0)


func _on_peer_left(peer_id: int) -> void:
	if _role != "host" or _game_state == null or peer_id <= 1:
		return
	if _game_state.get_snapshot().phase != GameEnums.GamePhase.ACTIVE:
		_fail("A peer left outside the active-match scenario.")
		return
	_disconnect_peer_id = peer_id
	if not _game_state.resolve_round(-1, GameEnums.RoundEndReason.DISCONNECT):
		_fail("Host did not invalidate the round after a disconnection.")
		return
	var snapshot: Dictionary = _game_state.get_snapshot()
	if not _is_disconnect_result(snapshot):
		_fail("Host disconnect result has an invalid winner, reason or score.")
		return
	_mark("host-match-invalidated")
	_probe.receive_game_snapshot(snapshot)
	_probe.receive_game_snapshot.rpc(snapshot)
	print("DISCONNECT_HOST_MATCH_INVALIDATED peer=%d" % peer_id)


func _on_game_snapshot(snapshot: Dictionary) -> void:
	if _role != "client" or _player_name == "client1":
		return
	if not _is_disconnect_result(snapshot):
		_fail("Connected client received a mismatched disconnect result.")
		return
	_mark("%s-match-invalidated" % _player_name)
	_probe.acknowledge_snapshot.rpc_id(1)
	print("DISCONNECT_CLIENT_RESULT_RECEIVED name=%s" % _player_name)
	await create_timer(0.5).timeout
	quit(0)


func _on_snapshot_ack(peer_id: int) -> void:
	_acks[peer_id] = true
	if _acks.size() >= 4:
		_mark("host-connected-clients-confirmed")
		quit(0)


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
