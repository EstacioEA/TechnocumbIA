class_name RoleCombatSystem
extends RefCounted

## Host-authoritative MVP for roles, Papa transport, combat, lives and Beast.

const PAPA_IMMOBILIZATION_SECONDS := 20.0
const PAPA_DROP_STUN_SECONDS := 3.0
const ATTACKER_RESPAWN_SECONDS := 3.0
const BEAST_APPEARANCE_SECONDS := 30.0
const ATTACKER_STARTING_LIVES := 3
const PORTA_PAPAS_SPRINT_REDUCTION_SECONDS := 2.0 # Temporary balance value.
const PORTA_PAPAS_SPRINT_COOLDOWN_SECONDS := 4.0 # Temporary balance value.
const TROLLAZZO_TRAP_COOLDOWN_SECONDS := 8.0 # Temporary balance value.
const BEAST_BASIC_COOLDOWN_SECONDS := 3.0 # Temporary balance value.
const BEAST_SPECIAL_COOLDOWN_SECONDS := 10.0 # Temporary balance value.
const BEAST_ENRAGED_COOLDOWN_MULTIPLIER := 0.5 # Temporary balance value.
const BEAST_ENRAGED_SPEED_MULTIPLIER := 1.25 # Temporary balance value.
const TANK_TRAP_DAMAGE_MULTIPLIER := 0.5 # Temporary balance value.
const HUNTER_BEAST_DAMAGE_MULTIPLIER := 1.25 # Temporary balance value.

const ROLE_PAPA := &"Papa"
const ROLE_TROLLAZZO := &"Trolazzo"
const ROLE_BEAST := &"Bestia"
const PASSIVE_TANK := &"Tanque"
const PASSIVE_HUNTER := &"Cazador"
const PASSIVE_PORTA_PAPAS := &"Porta Papas"

var is_host := false
var round_elapsed := 0.0
var pot_is_cooking := false
var papa_player_id: int = -1
var papa_carrier_id: int = -1
var papa_immobilized_remaining := 0.0
var beast_appeared := false
var beast_enraged := false
var players: Dictionary = {}
var traps: Array[Dictionary] = []

func _init(host_authority: bool = false) -> void:
	is_host = host_authority

func start_round(player_ids: Array[int], attacker_ids: Array[int], defender_ids: Array[int]) -> bool:
	if not _host_only():
		return false
	if attacker_ids.size() != 3 or defender_ids.size() != 3:
		return false
	players.clear()
	traps.clear()
	round_elapsed = 0.0
	pot_is_cooking = false
	papa_carrier_id = -1
	papa_immobilized_remaining = 0.0
	beast_appeared = false
	beast_enraged = false
	papa_player_id = -1

	for player_id in player_ids:
		players[player_id] = {
			"team": &"attacker" if player_id in attacker_ids else &"defender",
			"role": &"",
			"passive": &"",
			"lives": ATTACKER_STARTING_LIVES if player_id in attacker_ids else 0,
			"active": true,
			"respawn_remaining": 0.0,
			"stun_remaining": 0.0,
			"cooldowns": {},
			"speed_multiplier": 1.0,
		}

	for index in defender_ids.size():
		var player_id: int = defender_ids[index]
		var role := [ROLE_PAPA, ROLE_TROLLAZZO, ROLE_BEAST][index]
		players[player_id]["role"] = role
		if role == ROLE_PAPA:
			papa_player_id = player_id

	for index in attacker_ids.size():
		players[attacker_ids[index]]["passive"] = [
			PASSIVE_TANK, PASSIVE_HUNTER, PASSIVE_PORTA_PAPAS
		][index]
	return papa_player_id != -1

func tick(delta: float) -> void:
	if not _host_only() or delta <= 0.0:
		return
	round_elapsed += delta
	if not beast_appeared and round_elapsed >= BEAST_APPEARANCE_SECONDS:
		beast_appeared = true
		var beast_id := _player_with_role(ROLE_BEAST)
		if beast_id != -1:
			players[beast_id]["active"] = true

	papa_immobilized_remaining = maxf(0.0, papa_immobilized_remaining - delta)
	for player_id in players:
		var state: Dictionary = players[player_id]
		state["stun_remaining"] = maxf(0.0, state["stun_remaining"] - delta)
		state["respawn_remaining"] = maxf(0.0, state["respawn_remaining"] - delta)
		if state["respawn_remaining"] == 0.0 and not state["active"] and state["lives"] > 0:
			state["active"] = true
		var cooldowns: Dictionary = state["cooldowns"]
		for action in cooldowns:
			cooldowns[action] = maxf(0.0, float(cooldowns[action]) - delta)

func request_capture_papa(actor_id: int) -> bool:
	if not _host_only() or not _is_active_attacker(actor_id):
		return false
	if papa_player_id == -1 or papa_carrier_id != -1 or papa_immobilized_remaining > 0.0:
		return false
	if not players[papa_player_id]["active"]:
		return false
	papa_carrier_id = actor_id
	papa_immobilized_remaining = PAPA_IMMOBILIZATION_SECONDS
	return true

func request_porta_papas_sprint(actor_id: int) -> bool:
	if not _host_only() or not _is_active_attacker(actor_id):
		return false
	if players[actor_id]["passive"] != PASSIVE_PORTA_PAPAS:
		return false
	if not _cooldown_ready(actor_id, &"sprint"):
		return false
	_set_cooldown(actor_id, &"sprint", PORTA_PAPAS_SPRINT_COOLDOWN_SECONDS)
	if papa_carrier_id == actor_id:
		papa_immobilized_remaining = maxf(
			0.0, papa_immobilized_remaining - PORTA_PAPAS_SPRINT_REDUCTION_SECONDS
		)
	return true

func request_drop_papa(actor_id: int) -> bool:
	if not _host_only() or papa_carrier_id != actor_id:
		return false
	_drop_papa()
	players[actor_id]["stun_remaining"] = PAPA_DROP_STUN_SECONDS
	return true

func request_hit_attacker(attacker_id: int) -> bool:
	if not _host_only() or not _is_active_attacker(attacker_id):
		return false
	if papa_carrier_id == attacker_id:
		_drop_papa()
		players[attacker_id]["stun_remaining"] = PAPA_DROP_STUN_SECONDS
		return true
	var state: Dictionary = players[attacker_id]
	state["lives"] = maxi(0, int(state["lives"]) - 1)
	state["active"] = false
	state["respawn_remaining"] = ATTACKER_RESPAWN_SECONDS if state["lives"] > 0 else 0.0
	return true

func request_beast_basic_attack(target_id: int) -> bool:
	return _request_beast_attack(target_id, &"beast_basic", BEAST_BASIC_COOLDOWN_SECONDS)

func request_beast_special_attack(target_id: int) -> bool:
	return _request_beast_attack(target_id, &"beast_special", BEAST_SPECIAL_COOLDOWN_SECONDS)

func can_beast_enter_pot_room() -> bool:
	return pot_is_cooking

func begin_pot_cooking() -> bool:
	if not _host_only() or papa_carrier_id == -1:
		return false
	pot_is_cooking = true
	return true

func finish_pot_cooking() -> bool:
	if not _host_only() or not pot_is_cooking:
		return false
	pot_is_cooking = false
	papa_carrier_id = -1
	papa_immobilized_remaining = 0.0
	beast_enraged = true
	var beast_id := _player_with_role(ROLE_BEAST)
	if beast_id != -1:
		players[beast_id]["speed_multiplier"] = BEAST_ENRAGED_SPEED_MULTIPLIER
	return true

func request_trollazzo_trap(trap_position: Vector2) -> bool:
	if not _host_only():
		return false
	var trollazzo_id := _player_with_role(ROLE_TROLLAZZO)
	if trollazzo_id == -1 or not _cooldown_ready(trollazzo_id, &"trap"):
		return false
	_set_cooldown(trollazzo_id, &"trap", TROLLAZZO_TRAP_COOLDOWN_SECONDS)
	traps.append({"position": trap_position, "active": true})
	return true

func get_trap_damage_multiplier(player_id: int) -> float:
	if player_id in players and players[player_id]["passive"] == PASSIVE_TANK:
		return TANK_TRAP_DAMAGE_MULTIPLIER
	return 1.0

func get_beast_damage_multiplier(attacker_id: int) -> float:
	if attacker_id in players and players[attacker_id]["passive"] == PASSIVE_HUNTER:
		return HUNTER_BEAST_DAMAGE_MULTIPLIER
	return 1.0

func get_player_state(player_id: int) -> Dictionary:
	if not players.has(player_id):
		return {}
	return players[player_id].duplicate(true)

func _request_beast_attack(target_id: int, action: StringName, base_cooldown: float) -> bool:
	if not _host_only() or not beast_appeared:
		return false
	var beast_id := _player_with_role(ROLE_BEAST)
	if beast_id == -1 or not _cooldown_ready(beast_id, action):
		return false
	if target_id not in players or players[target_id]["team"] != &"attacker":
		return false
	var cooldown := base_cooldown
	if beast_enraged:
		cooldown *= BEAST_ENRAGED_COOLDOWN_MULTIPLIER
	_set_cooldown(beast_id, action, cooldown)
	return players[target_id]["active"]

func _drop_papa() -> void:
	papa_carrier_id = -1
	papa_immobilized_remaining = 0.0

func _player_with_role(role: StringName) -> int:
	for player_id in players:
		if players[player_id]["role"] == role:
			return player_id
	return -1

func _is_active_attacker(player_id: int) -> bool:
	return player_id in players and players[player_id]["team"] == &"attacker" \
		and players[player_id]["active"] and players[player_id]["stun_remaining"] <= 0.0

func _cooldown_ready(player_id: int, action: StringName) -> bool:
	return float(players[player_id]["cooldowns"].get(action, 0.0)) <= 0.0

func _set_cooldown(player_id: int, action: StringName, duration: float) -> void:
	players[player_id]["cooldowns"][action] = maxf(0.0, duration)

func _host_only() -> bool:
	return is_host
