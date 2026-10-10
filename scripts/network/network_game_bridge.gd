extends Node
class_name NetworkGameBridge

signal snapshot_updated(snapshot: Dictionary)
signal match_invalidated(snapshot: Dictionary)

const GameEnums = preload("res://scripts/shared/game_enums.gd")

@onready var _network_manager: Node = get_parent().get_node("NetworkManager")
@onready var _game_state: Node = get_parent().get_node("GameState")

var _match_initialized := false
var _disconnect_resolved := false
var _last_published_revision := -1


func _ready() -> void:
	_network_manager.lobby_start.connect(_on_lobby_start)
	_network_manager.peer_left.connect(_on_peer_left)


func _on_lobby_start() -> void:
	if not _network_manager.multiplayer.is_server() or _match_initialized:
		return
	var roster: Array[Dictionary] = []
	for peer_id: int in _network_manager.players:
		var player: Dictionary = _network_manager.players[peer_id]
		roster.append({"peer_id": peer_id, "ready": bool(player.get("ready", false))})
	if not _game_state.configure_lobby(roster) or not _game_state.start_match():
		_network_manager.status_changed.emit("No se pudo preparar el estado autoritativo de la partida.")
		return
	_match_initialized = true
	_game_state.phase_changed.connect(_on_game_phase_changed)
	_game_state.round_finished.connect(_on_game_round_finished)
	_publish_state_snapshot()


func _on_peer_left(peer_id: int) -> void:
	if not _is_active_host() or not _match_initialized or _disconnect_resolved or peer_id <= 1:
		return
	var phase: int = _game_state.get_snapshot().phase
	if phase not in [GameEnums.GamePhase.COUNTDOWN, GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE]:
		return
	if not _game_state.resolve_round(-1, GameEnums.RoundEndReason.DISCONNECT):
		_network_manager.status_changed.emit("No se pudo invalidar la partida tras una desconexión.")
		return
	_disconnect_resolved = true
	var snapshot: Dictionary = _game_state.get_snapshot()
	match_invalidated.emit(snapshot)
	call_deferred("_show_disconnect_notice")


func _show_disconnect_notice() -> void:
	_network_manager.status_changed.emit("Partida invalidada: un jugador se desconectó.")


func _on_game_phase_changed(_previous_phase: int, _current_phase: int) -> void:
	call_deferred("_publish_state_snapshot")


func _on_game_round_finished(_winner_team: int, _reason: int, _snapshot: Dictionary) -> void:
	call_deferred("_publish_state_snapshot")


func _publish_state_snapshot() -> void:
	if not _is_active_host() or not _match_initialized:
		return
	var snapshot: Dictionary = _game_state.get_snapshot()
	var revision := int(snapshot.get("revision", -1))
	if revision < 0 or revision <= _last_published_revision:
		return
	_last_published_revision = revision
	snapshot_updated.emit(snapshot)
	_rpc_apply_host_snapshot.rpc(snapshot)


func _is_active_host() -> bool:
	var peer: MultiplayerPeer = _network_manager.multiplayer.multiplayer_peer
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return false
	return _network_manager.multiplayer.is_server()


@rpc("authority", "call_remote", "reliable")
func _rpc_apply_host_snapshot(snapshot: Dictionary) -> void:
	if _network_manager.multiplayer.is_server() or typeof(snapshot) != TYPE_DICTIONARY:
		return
	if not _game_state.apply_host_snapshot(snapshot):
		_network_manager.status_changed.emit("Se recibió un estado de partida inválido o desactualizado.")
		return
	var applied_snapshot: Dictionary = _game_state.get_snapshot()
	snapshot_updated.emit(applied_snapshot)
	if applied_snapshot.phase == GameEnums.GamePhase.MATCH_RESULT and applied_snapshot.round_end_reason == GameEnums.RoundEndReason.DISCONNECT:
		_network_manager.status_changed.emit("Partida invalidada: un jugador se desconectó.")
