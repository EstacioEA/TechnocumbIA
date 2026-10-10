extends SceneTree

const LobbyScene = preload("res://scenes/lobby/lobby.tscn")
const TEST_ADDRESS := "127.0.0.1"
const TIMEOUT_SECONDS := 35.0

var _lobby: Control
var _manager: Node
var _role := ""
var _player_name := ""
var _marker_dir := ""
var _checked_five := false
var _checked_unready_six := false
var _client_start_attempted := false
var _host_ready_set := false
var _start_requested := false
var _start_event_received := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 4:
		_fail("Uso: ready_start_test.gd -- <host|client> <port> <name> <marker_dir>")
		return
	_role = str(args[0])
	var port_text := str(args[1])
	_player_name = str(args[2])
	_marker_dir = str(args[3])
	if not port_text.is_valid_int() or _role not in ["host", "client"]:
		_fail("Argumentos inválidos para el test ready/start.")
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
	_manager.lobby_start.connect(_on_lobby_start)
	_manager.status_changed.connect(_on_status_changed)

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
		if snapshot.size() == 5 and not _checked_five:
			_checked_five = true
			if not _check_host_start_button(true):
				return
		if snapshot.size() == 5 and not _manager.request_start_match():
			var status_label: Label = _lobby.get("_status_label")
			if not status_label.text.contains("seis"):
				_fail("El rechazo con cinco jugadores no comunicó el límite.")
				return
			_mark("host-five-start-blocked")
		elif snapshot.size() == 5 and not _manager.players.size() >= 6:
			# The fifth roster update must never start the match.
			if _start_event_received:
				_fail("El host inició la partida antes de tener seis jugadores.")
				return

		if snapshot.size() == 6 and not _checked_unready_six:
			_checked_unready_six = true
			if not _check_host_start_button(true):
				return
			if _manager.request_start_match():
				_fail("El host inició sin que todos los jugadores estuvieran listos.")
				return
			var status_label: Label = _lobby.get("_status_label")
			if not status_label.text.contains("Todos los jugadores"):
				_fail("El bloqueo por jugadores no listos no se mostró al host.")
				return
			_mark("host-unready-start-blocked")
			_host_ready_set = _manager.set_local_ready(true)
			if not _host_ready_set:
				_fail("El host no pudo marcarse listo.")
				return
			_mark("host-ready-set")

		if snapshot.size() == 6 and _all_players_ready() and not _start_requested:
			_start_requested = true
			call_deferred("_start_when_all_ready")
		return

	if _manager.multiplayer.multiplayer_peer == null:
		return
	if _client_start_attempted or snapshot.size() != 6 or not _snapshot_has_local_player(snapshot):
		return
	_client_start_attempted = true
	if not _check_client_start_button_disabled():
		return
	if not _manager.request_start_match():
		var status_label: Label = _lobby.get("_status_label")
		if not status_label.text.contains("Solo el host"):
			_fail("Al cliente se le negó el inicio sin mostrar la causa.")
			return
	else:
		_fail("Un cliente inició la partida sin ser host.")
		return
	_mark("%s-client-start-blocked" % _player_name)

	if _manager.set_local_ready(true):
		_mark("%s-ready-requested" % _player_name)
	else:
		_fail("El cliente no pudo enviar su estado ready.")


func _start_when_all_ready() -> void:
	if _role != "host" or not _all_players_ready() or not _host_ready_set:
		_fail("Se intentó iniciar antes de que los seis jugadores estuvieran listos.")
		return
	if not _check_host_start_button(false):
		return
	if not _manager.request_start_match():
		_fail("El host no pudo iniciar con seis jugadores listos.")
		return
	print("HOST_START_REQUEST_ACCEPTED")


func _on_lobby_start() -> void:
	if _start_event_received:
		_fail("Se recibió lobby_start más de una vez.")
		return
	_start_event_received = true
	if _manager.players.size() != 6 or not _all_players_ready():
		_fail("lobby_start llegó sin seis jugadores listos.")
		return
	if _role == "host":
		if not _start_requested:
			_fail("El host recibió inicio sin haber aceptado la solicitud.")
			return
		_mark("host-start-received")
		print("HOST_LOBBY_START")
		_finish_after_start()
	else:
		if not _check_client_start_button_disabled():
			return
		var players_label: Label = _lobby.get("_players_label")
		if players_label.text.split("LISTO").size() - 1 != 6:
			_fail("La UI cliente no muestra a los seis jugadores listos.")
			return
		_mark("%s-lobby-start-received" % _player_name)
		print("CLIENT_LOBBY_START name=%s" % _player_name)
		_finish_after_start()


func _finish_after_start() -> void:
	await create_timer(1.0).timeout
	quit(0)


func _check_host_start_button(expected_disabled: bool) -> bool:
	var start_button: Button = _lobby.get("_start_button")
	if not start_button.visible or start_button.disabled != expected_disabled:
		_fail("Estado host incorrecto del botón iniciar: visible=%s disabled=%s." % [start_button.visible, start_button.disabled])
		return false
	return true


func _check_client_start_button_disabled() -> bool:
	var start_button: Button = _lobby.get("_start_button")
	if not start_button.visible or not start_button.disabled:
		_fail("El botón iniciar debe mostrarse deshabilitado para un cliente.")
		return false
	return true


func _check_all_players_waiting(snapshot: Array[Dictionary]) -> bool:
	for entry: Dictionary in snapshot:
		if bool(entry.get("ready", true)):
			_fail("El host transmitió un jugador listo antes de iniciar la comprobación.")
			return false
	return true


func _snapshot_has_local_player(snapshot: Array[Dictionary]) -> bool:
	var peer: MultiplayerPeer = _manager.multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return false
	var local_id: int = _manager.multiplayer.get_unique_id()
	for entry: Dictionary in snapshot:
		if entry.get("id") == local_id:
			return true
	return false


func _all_players_ready() -> bool:
	if _manager.players.size() != 6:
		return false
	for player_data: Dictionary in _manager.players.values():
		if not bool(player_data.get("ready", false)):
			return false
	return true


func _on_status_changed(message: String) -> void:
	if message.begins_with("No se pudo conectar") or message.begins_with("Se perdió la conexión"):
		_fail("Conexión inesperada durante ready/start: %s" % message)


func _mark(name: String) -> void:
	var marker := FileAccess.open(_marker_dir.path_join("%s.ok" % name), FileAccess.WRITE)
	if marker == null:
		_fail("No se pudo escribir el marcador %s." % name)
		return
	marker.store_string("PASS\n")
	marker.close()


func _fail(message: String) -> void:
	printerr("READY_START_TEST_FAIL role=%s name=%s: %s" % [_role, _player_name, message])
	quit(1)
