extends SceneTree

const LobbyScene = preload("res://scenes/lobby/lobby.tscn")
const TEST_ADDRESS := "127.0.0.1"
const TIMEOUT_SECONDS := 40.0

var _lobby: Control
var _manager: Node
var _role := ""
var _player_name := ""
var _marker_dir := ""
var _saw_six := false
var _saw_peer_left := false
var _saw_roster_five := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 4:
		_fail("Uso: lobby_slots_test.gd -- <host|drop|observer|member|seventh> <port> <name> <marker_dir>")
		return
	_role = str(args[0])
	var port_text := str(args[1])
	_player_name = str(args[2])
	_marker_dir = str(args[3])
	if not port_text.is_valid_int() or _role not in ["host", "drop", "observer", "member", "seventh"]:
		_fail("Argumentos inválidos para el test de lobby.")
		return
	if not DirAccess.dir_exists_absolute(_marker_dir):
		var mkdir_error := DirAccess.make_dir_recursive_absolute(_marker_dir)
		if mkdir_error != OK:
			_fail("No se pudo crear el directorio temporal de marcadores.")
			return

	_lobby = LobbyScene.instantiate()
	root.add_child(_lobby)
	await process_frame
	_manager = _lobby.get_node("NetworkManager")
	_manager.lobby_updated.connect(_on_lobby_updated)
	_manager.peer_left.connect(_on_peer_left)
	_manager.lobby_rejected.connect(_on_lobby_rejected)

	var port := port_text.to_int()
	if _role == "host":
		if _manager.host_game(port) != OK:
			_fail("No se pudo crear el host ENet en el puerto %d." % port)
			return
		_mark("host-ready")
		print("HOST_READY port=%d" % port)
	else:
		if _manager.join_game(TEST_ADDRESS, port) != OK:
			_fail("No se pudo iniciar la conexión para %s." % _player_name)
			return
		print("CLIENT_CONNECTING name=%s" % _player_name)

	var timer := create_timer(TIMEOUT_SECONDS)
	timer.timeout.connect(func() -> void: _fail("Timeout para %s (%s)." % [_player_name, _role]))


func _on_lobby_updated(snapshot: Array[Dictionary]) -> void:
	if _role == "host":
		if snapshot.size() == 6 and not _saw_six:
			if not _check_visible_rows(6):
				return
			_saw_six = true
			_mark("host-roster-six")
			print("HOST_ROSTER_SIX")
		elif snapshot.size() == 5 and _saw_six and _saw_peer_left:
			if not _check_visible_rows(5):
				return
			_mark("host-roster-five")
			print("HOST_ROSTER_FIVE")
			quit(0)
		return

	var peer: MultiplayerPeer = _manager.multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	var local_id: int = _manager.multiplayer.get_unique_id()
	var local_player_present := false
	for entry: Dictionary in snapshot:
		if entry.get("id") == local_id:
			local_player_present = true
			break
	if snapshot.size() == 6 and local_player_present and not _saw_six:
		if not _check_visible_rows(6):
			return
		_saw_six = true
		_mark("%s-roster-six" % _player_name)
		print("CLIENT_ROSTER_SIX name=%s" % _player_name)
		if _role == "drop":
			_drop_after_delay()
	elif snapshot.size() == 5 and _saw_six and _saw_peer_left:
		if not _check_visible_rows(5):
			return
		if _role == "observer" and not _saw_roster_five:
			_saw_roster_five = true
			_mark("observer-roster-five")
			print("OBSERVER_ROSTER_FIVE")
			quit(0)


func _on_peer_left(peer_id: int) -> void:
	if peer_id > 1:
		_saw_peer_left = true


func _on_lobby_rejected(reason: String) -> void:
	if _role == "member" and reason.contains("host"):
		print("MEMBER_HOST_SHUTDOWN_AFTER_TEST")
		quit(0)
		return
	if _role != "seventh":
		_fail("Jugador aceptado inesperadamente/rechazado: %s" % reason)
		return
	var status_label: Label = _lobby.get("_status_label")
	if not reason.contains("seis") and not reason.contains("lleno"):
		_fail("La causa del rechazo no menciona el límite: %s" % reason)
		return
	if not status_label.text.contains(reason):
		_fail("La causa del rechazo no quedó visible en la UI: %s" % status_label.text)
		return
	_mark("seventh-rejected")
	print("SEVENTH_REJECTED reason=%s" % reason)
	quit(0)


func _drop_after_delay() -> void:
	await create_timer(1.0).timeout
	_manager.close_session()
	_mark("drop-disconnected")
	print("DROP_DISCONNECTED")
	quit(0)


func _check_visible_rows(expected: int) -> bool:
	var players_label: Label = _lobby.get("_players_label")
	var rows := players_label.text.split("\n").size()
	if rows != expected:
		_fail("La UI muestra %d filas; se esperaban %d. Texto: %s" % [rows, expected, players_label.text])
		return false
	return true


func _mark(name: String) -> void:
	var marker := FileAccess.open(_marker_dir.path_join("%s.ok" % name), FileAccess.WRITE)
	if marker == null:
		_fail("No se pudo escribir el marcador %s." % name)
		return
	marker.store_string("PASS\n")
	marker.close()


func _fail(message: String) -> void:
	printerr("LOBBY_SLOTS_TEST_FAIL role=%s name=%s: %s" % [_role, _player_name, message])
	quit(1)
