class_name BeastAccessState
extends RefCounted

const BEAST_APPEARANCE_SECONDS := 30.0
const BASIC_ATTACK_COOLDOWN_SECONDS := 5.0
const SPECIAL_ATTACK_COOLDOWN_SECONDS := 10.0

const ACTION_BASIC := &"beast_basic"
const ACTION_SPECIAL := &"beast_special"

var host_authority := false
var beast_id := -1
var attacker_ids: Array[int] = []
var round_elapsed := 0.0
var appeared := false
var pot_is_cooking := false
var cooldowns: Dictionary = {}
var last_attack: Dictionary = {}

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func configure_round(defender_ids: Array[int], attackers: Array[int]) -> bool:
	if not _host_only() or defender_ids.is_empty() or attackers.is_empty():
		return false
	beast_id = defender_ids[0]
	attacker_ids = attackers.duplicate()
	round_elapsed = 0.0
	appeared = false
	pot_is_cooking = false
	cooldowns.clear()
	last_attack.clear()
	return true

func tick(delta: float) -> void:
	if not _host_only() or delta <= 0.0:
		return
	round_elapsed += delta
	if not appeared and round_elapsed >= BEAST_APPEARANCE_SECONDS:
		appeared = true
	for action in cooldowns:
		cooldowns[action] = maxf(0.0, float(cooldowns[action]) - delta)

func set_pot_cooking(cooking: bool) -> bool:
	if not _host_only():
		return false
	pot_is_cooking = cooking
	return true

func can_enter_pot_room() -> bool:
	return pot_is_cooking

func request_basic_attack(target_id: int) -> bool:
	return _request_attack(target_id, ACTION_BASIC, BASIC_ATTACK_COOLDOWN_SECONDS)

func request_special_attack(target_id: int) -> bool:
	return _request_attack(target_id, ACTION_SPECIAL, SPECIAL_ATTACK_COOLDOWN_SECONDS)

func get_snapshot() -> Dictionary:
	return {
		"beast_id": beast_id,
		"appeared": appeared,
		"round_elapsed": round_elapsed,
		"pot_is_cooking": pot_is_cooking,
		"cooldowns": cooldowns.duplicate(),
		"last_attack": last_attack.duplicate(),
	}

func _request_attack(target_id: int, action: StringName, duration: float) -> bool:
	if not _host_only() or not appeared or target_id not in attacker_ids:
		return false
	if float(cooldowns.get(action, 0.0)) > 0.0:
		return false
	cooldowns[action] = maxf(0.0, duration)
	last_attack = {"action": action, "target_id": target_id}
	return true

func _host_only() -> bool:
	return host_authority
