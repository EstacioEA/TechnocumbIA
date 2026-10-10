class_name CombatLivesState
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")

const STARTING_LIVES := 3
const RESPAWN_SECONDS := 3.0

var host_authority := false
var attacker_ids: Array[int] = []
var lives: Dictionary = {}
var active: Dictionary = {}
var respawn_remaining: Dictionary = {}
var defender_win_triggered := false

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func start_round(player_ids: Array[int], attackers: Array[int]) -> bool:
	if not _host_only() or attackers.is_empty() or attackers.size() > player_ids.size():
		return false
	var unique_players: Array = player_ids.duplicate()
	var unique_attackers: Array = attackers.duplicate()
	if unique_players.size() != player_ids.size() or unique_attackers.size() != attackers.size():
		return false
	for attacker_id in attackers:
		if attacker_id not in player_ids:
			return false
	attacker_ids = unique_attackers
	lives.clear()
	active.clear()
	respawn_remaining.clear()
	defender_win_triggered = false
	for player_id in player_ids:
		active[player_id] = true
		respawn_remaining[player_id] = 0.0
		if player_id in attackers:
			lives[player_id] = STARTING_LIVES
	return true

func tick(delta: float) -> void:
	if not _host_only() or delta <= 0.0:
		return
	for player_id in attacker_ids:
		if active.get(player_id, false):
			continue
		respawn_remaining[player_id] = maxf(
			0.0, float(respawn_remaining.get(player_id, 0.0)) - delta
		)
		if respawn_remaining[player_id] <= 0.0001 and lives.get(player_id, 0) > 0:
			respawn_remaining[player_id] = 0.0
			active[player_id] = true
	if _all_attackers_eliminated():
		defender_win_triggered = true

func request_hit_without_papa(attacker_id: int, carrying_papa: bool) -> bool:
	if not _host_only() or attacker_id not in attacker_ids:
		return false
	if not active.get(attacker_id, false) or carrying_papa:
		return false
	var remaining: int = maxi(0, int(lives.get(attacker_id, 0)) - 1)
	lives[attacker_id] = remaining
	active[attacker_id] = false
	respawn_remaining[attacker_id] = RESPAWN_SECONDS if remaining > 0 else 0.0
	if remaining == 0:
		defender_win_triggered = _all_attackers_eliminated()
	return true

func get_player_state(attacker_id: int) -> Dictionary:
	if attacker_id not in attacker_ids:
		return {}
	return {
		"lives": int(lives.get(attacker_id, 0)),
		"active": bool(active.get(attacker_id, false)),
		"respawn_remaining": float(respawn_remaining.get(attacker_id, 0.0)),
	}

func should_defenders_win() -> bool:
	return defender_win_triggered

func _all_attackers_eliminated() -> bool:
	for attacker_id in attacker_ids:
		if int(lives.get(attacker_id, 0)) > 0:
			return false
	return not attacker_ids.is_empty()

func _host_only() -> bool:
	return host_authority
