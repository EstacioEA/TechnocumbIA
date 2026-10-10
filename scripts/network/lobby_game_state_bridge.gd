extends Node
## Starts the authoritative GameState after the LAN host accepts the ready lobby.

signal match_started(snapshot: Dictionary)
signal integration_failed(reason: String)

@export_node_path("Node") var network_manager_path: NodePath
@export_node_path("Node") var game_state_path: NodePath

var _network_manager: Node
var _game_state: Node
var _started := false


func _ready() -> void:
	_network_manager = get_node_or_null(network_manager_path)
	_game_state = get_node_or_null(game_state_path)
	if _network_manager == null or _game_state == null:
		_fail("Configura las rutas de NetworkManager y GameState en LobbyGameStateBridge.")
		return
	if not _network_manager.has_signal("lobby_start"):
		_fail("NetworkManager no expone la señal lobby_start.")
		return
	if not _network_manager.has_method("get_lobby_snapshot"):
		_fail("NetworkManager no expone get_lobby_snapshot().")
		return
	if not _game_state.has_method("configure_lobby") or not _game_state.has_method("start_match"):
		_fail("GameState debe exponer configure_lobby() y start_match().")
		return
	_network_manager.connect("lobby_start", _on_lobby_start)


static func build_game_state_roster(snapshot: Array[Dictionary]) -> Dictionary:
	if snapshot.size() != 6:
		return {"valid": false, "roster": [], "reason": "GameState requiere exactamente seis jugadores."}
	var peer_ids: Dictionary = {}
	var roster: Array[Dictionary] = []
	for player: Dictionary in snapshot:
		if not player.has("id") or not player.has("ready"):
			return {"valid": false, "roster": [], "reason": "Cada jugador requiere id y ready."}
		if typeof(player["id"]) != TYPE_INT or player["id"] <= 0 or typeof(player["ready"]) != TYPE_BOOL:
			return {"valid": false, "roster": [], "reason": "id debe ser positivo y ready debe ser booleano."}
		if peer_ids.has(player["id"]):
			return {"valid": false, "roster": [], "reason": "El roster contiene peer_id duplicados."}
		if not player["ready"]:
			return {"valid": false, "roster": [], "reason": "Todos los jugadores deben estar listos."}
		peer_ids[player["id"]] = true
		roster.append({"peer_id": player["id"], "ready": true})
	return {"valid": true, "roster": roster, "reason": ""}


func _on_lobby_start() -> void:
	if _started or not _network_manager.multiplayer.is_server():
		return
	var lobby_snapshot: Array[Dictionary] = _network_manager.call("get_lobby_snapshot")
	var conversion: Dictionary = build_game_state_roster(lobby_snapshot)
	if not conversion["valid"]:
		_fail(conversion["reason"])
		return
	if not _game_state.call("configure_lobby", conversion["roster"]):
		_fail("GameState rechazó el roster del lobby.")
		return
	if not _game_state.call("start_match"):
		_fail("GameState no pudo iniciar la partida.")
		return
	_started = true
	match_started.emit(_game_state.call("get_snapshot"))
	_report_status("Partida iniciada por el host.")


func _fail(reason: String) -> void:
	integration_failed.emit(reason)
	push_error("LobbyGameStateBridge: " + reason)
	_report_status(reason)


func _report_status(message: String) -> void:
	if _network_manager != null and _network_manager.has_signal("status_changed"):
		_network_manager.emit_signal("status_changed", message)
