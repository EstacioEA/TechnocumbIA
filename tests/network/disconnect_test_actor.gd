extends Node

signal snapshot_received(snapshot: Dictionary)
signal ack_received(peer_id: int)


@rpc("authority", "call_remote", "reliable")
func receive_game_snapshot(snapshot: Dictionary) -> void:
	snapshot_received.emit(snapshot)


@rpc("any_peer", "call_remote", "reliable")
func acknowledge_snapshot() -> void:
	if not multiplayer.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if peer_id > 1:
		ack_received.emit(peer_id)
