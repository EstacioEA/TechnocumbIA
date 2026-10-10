extends Node
## LAN lobby transport. The host owns the lobby roster and is peer 1.

signal peer_joined(peer_id: int, display_name: String, ready: bool)
signal peer_left(peer_id: int)
signal ready_changed(peer_id: int, ready: bool)
signal lobby_rejected(reason: String)
signal lobby_start
signal lobby_updated(players: Array[Dictionary])
signal status_changed(message: String)

const MAX_PLAYERS := 6
const MAX_REMOTE_CONNECTIONS := 32
const DEFAULT_PORT := 2456

var players: Dictionary = {}
var _last_lobby_error := ""


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func validate_ip(address: String) -> bool:
	return address.strip_edges().is_valid_ip_address()


func validate_port(port: int) -> bool:
	return port >= 1 and port <= 65535


func host_game(port: int = DEFAULT_PORT) -> Error:
	if not validate_port(port):
		return _fail("El puerto debe estar entre 1 y 65535.")
	close_session()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port, MAX_REMOTE_CONNECTIONS)
	if result != OK:
		return _fail("No se pudo crear el servidor en el puerto %d (código %d)." % [port, result])
	multiplayer.multiplayer_peer = peer
	players.clear()
	players[multiplayer.get_unique_id()] = {"name": "Host", "ready": false}
	_last_lobby_error = ""
	status_changed.emit("Servidor listo en el puerto %d." % port)
	_emit_lobby_updated()
	return OK


func join_game(address: String, port: int) -> Error:
	var clean_address := address.strip_edges()
	if not validate_ip(clean_address):
		return _fail("La dirección IP no es válida.")
	if not validate_port(port):
		return _fail("El puerto debe estar entre 1 y 65535.")
	close_session()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(clean_address, port)
	if result != OK:
		return _fail("No se pudo iniciar la conexión (código %d)." % result)
	multiplayer.multiplayer_peer = peer
	_last_lobby_error = ""
	status_changed.emit("Conectando a %s:%d…" % [clean_address, port])
	return OK


func close_session() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	players.clear()
	_emit_lobby_updated()


func set_local_ready(ready: bool) -> bool:
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		_fail("Conéctate a una partida antes de cambiar el estado listo.")
		return false
	if typeof(ready) != TYPE_BOOL:
		_fail("El estado listo debe ser verdadero o falso.")
		return false
	var local_id := multiplayer.get_unique_id()
	if multiplayer.is_server():
		_apply_ready(local_id, ready)
	else:
		_rpc_request_ready.rpc_id(1, ready)
	return true


func request_start_match() -> bool:
	if not multiplayer.is_server():
		_fail("Solo el host puede iniciar la partida.")
		return false
	if players.size() != MAX_PLAYERS:
		_fail("Se necesitan seis jugadores para iniciar (%d/6)." % players.size())
		return false
	for player_data: Dictionary in players.values():
		if not player_data.get("ready", false):
			_fail("Todos los jugadores deben estar listos.")
			return false
	_rpc_lobby_start.rpc()
	lobby_start.emit()
	status_changed.emit("El host inició la partida.")
	return true


func _fail(message: String) -> Error:
	_last_lobby_error = message
	status_changed.emit(message)
	return ERR_INVALID_PARAMETER


func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if players.size() >= MAX_PLAYERS:
		var reason := "Lobby lleno: el máximo es de seis jugadores."
		_rpc_lobby_rejected.rpc_id(peer_id, reason)
		get_tree().create_timer(0.25).timeout.connect(func() -> void:
			if multiplayer.multiplayer_peer != null:
				multiplayer.multiplayer_peer.disconnect_peer(peer_id)
		)
		return
	players[peer_id] = {"name": "Jugador %d" % peer_id, "ready": false}
	peer_joined.emit(peer_id, players[peer_id]["name"], false)
	status_changed.emit("Jugador %d se conectó." % peer_id)
	_broadcast_lobby()


func _on_peer_disconnected(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	players.erase(peer_id)
	peer_left.emit(peer_id)
	status_changed.emit("Jugador %d se desconectó." % peer_id)
	if multiplayer.is_server():
		_broadcast_lobby()
	else:
		_emit_lobby_updated()


func _on_connected_to_server() -> void:
	status_changed.emit("Conectado al host.")


func _on_connection_failed() -> void:
	var message := _last_lobby_error if not _last_lobby_error.is_empty() else "No se pudo conectar. Verifica la IP, el puerto y que el host esté activo."
	lobby_rejected.emit(message)
	status_changed.emit(message)
	players.clear()
	_emit_lobby_updated()


func _on_server_disconnected() -> void:
	var message := _last_lobby_error if not _last_lobby_error.is_empty() else "Se perdió la conexión con el host."
	for peer_id: int in players:
		peer_left.emit(peer_id)
	players.clear()
	lobby_rejected.emit(message)
	status_changed.emit(message)
	_emit_lobby_updated()


@rpc("any_peer", "call_remote", "reliable")
func _rpc_request_ready(ready: bool) -> void:
	if not multiplayer.is_server() or typeof(ready) != TYPE_BOOL:
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 1 or not players.has(sender):
		return
	_apply_ready(sender, ready)


func _apply_ready(peer_id: int, ready: bool) -> void:
	if not players.has(peer_id):
		return
	if players[peer_id]["ready"] == ready:
		return
	players[peer_id]["ready"] = ready
	ready_changed.emit(peer_id, ready)
	if multiplayer.is_server():
		_rpc_ready_changed.rpc(peer_id, ready)
		_broadcast_lobby()
	else:
		_emit_lobby_updated()


@rpc("authority", "call_remote", "reliable")
func _rpc_ready_changed(peer_id: int, ready: bool) -> void:
	if multiplayer.is_server() or typeof(peer_id) != TYPE_INT or typeof(ready) != TYPE_BOOL:
		return
	if not players.has(peer_id):
		return
	players[peer_id]["ready"] = ready
	ready_changed.emit(peer_id, ready)
	_emit_lobby_updated()


func _broadcast_lobby() -> void:
	var snapshot: Array[Dictionary] = get_lobby_snapshot()
	_apply_lobby_snapshot(snapshot)
	_rpc_lobby_snapshot.rpc(snapshot)


func get_lobby_snapshot() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for peer_id: int in players:
		var data: Dictionary = players[peer_id]
		snapshot.append({"id": peer_id, "name": str(data["name"]), "ready": bool(data["ready"])})
	snapshot.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["id"] < b["id"])
	return snapshot


@rpc("authority", "call_remote", "reliable")
func _rpc_lobby_snapshot(snapshot: Array[Dictionary]) -> void:
	if multiplayer.is_server() or snapshot.size() > MAX_PLAYERS:
		return
	_apply_lobby_snapshot(snapshot)


func _apply_lobby_snapshot(snapshot: Array[Dictionary]) -> void:
	var next_players: Dictionary = {}
	for entry: Dictionary in snapshot:
		if not entry.has("id") or not entry.has("name") or not entry.has("ready"):
			return
		if typeof(entry["id"]) != TYPE_INT or typeof(entry["name"]) != TYPE_STRING or typeof(entry["ready"]) != TYPE_BOOL:
			return
		if entry["id"] <= 0 or entry["name"].length() > 32:
			return
		next_players[entry["id"]] = {"name": entry["name"], "ready": entry["ready"]}
	if next_players.size() > MAX_PLAYERS:
		return
	var previous: Dictionary = players.duplicate(true)
	players = next_players
	for peer_id: int in players:
		if not previous.has(peer_id):
			peer_joined.emit(peer_id, players[peer_id]["name"], players[peer_id]["ready"])
		elif previous[peer_id]["ready"] != players[peer_id]["ready"]:
			ready_changed.emit(peer_id, players[peer_id]["ready"])
	for peer_id: int in previous:
		if not players.has(peer_id):
			peer_left.emit(peer_id)
	_emit_lobby_updated()


@rpc("authority", "call_remote", "reliable")
func _rpc_lobby_rejected(reason: String) -> void:
	if multiplayer.is_server() or typeof(reason) != TYPE_STRING or reason.length() > 160:
		return
	_last_lobby_error = reason
	lobby_rejected.emit(reason)
	status_changed.emit(reason)


@rpc("authority", "call_remote", "reliable")
func _rpc_lobby_start() -> void:
	if multiplayer.is_server() or players.size() != MAX_PLAYERS:
		return
	lobby_start.emit()
	status_changed.emit("El host inició la partida.")


func _emit_lobby_updated() -> void:
	lobby_updated.emit(get_lobby_snapshot())
