class_name TowerKeyState
extends RefCounted

var host_authority := false
var eligible_player_ids: Array[int] = []
var key_visible := false
var key_holder_id := -1
var key_position := Vector2.ZERO
var tower_open := false

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func configure_round(player_ids: Array[int]) -> bool:
	if not _host_only() or player_ids.is_empty():
		return false
	eligible_player_ids = player_ids.duplicate()
	key_visible = false
	key_holder_id = -1
	key_position = Vector2.ZERO
	tower_open = false
	return true

func spawn_at(position: Vector2) -> bool:
	if not _host_only() or tower_open or key_holder_id != -1:
		return false
	key_position = position
	key_visible = true
	return true

func request_collect(player_id: int, position: Vector2, papa_carrier_id: int, distance: float) -> bool:
	if not _host_only() or tower_open or not key_visible:
		return false
	if player_id not in eligible_player_ids or player_id == papa_carrier_id:
		return false
	if distance < 0.0 or position.distance_to(key_position) > distance:
		return false
	key_holder_id = player_id
	key_visible = false
	return true

func request_open_tower(player_id: int, position: Vector2, gate_position: Vector2, distance: float) -> bool:
	if not _host_only() or tower_open or key_holder_id != player_id:
		return false
	if distance < 0.0 or position.distance_to(gate_position) > distance:
		return false
	key_holder_id = -1
	tower_open = true
	return true

func drop_at(position: Vector2, player_id: int) -> bool:
	if not _host_only() or key_holder_id != player_id or tower_open:
		return false
	key_holder_id = -1
	key_position = position
	key_visible = true
	return true

func get_snapshot() -> Dictionary:
	return {
		"key_visible": key_visible,
		"key_holder_id": key_holder_id,
		"key_position": key_position,
		"tower_open": tower_open,
	}

func _host_only() -> bool:
	return host_authority
