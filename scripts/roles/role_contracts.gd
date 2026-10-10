class_name RoleContracts
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")

var host_authority := false

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func assign_round(
	player_ids: Array[int],
	attacker_ids: Array[int],
	defender_ids: Array[int],
	rng: RandomNumberGenerator
) -> Dictionary:
	if not host_authority or not _valid_roster(player_ids, attacker_ids, defender_ids):
		return {}

	var assignments: Array[Dictionary] = []
	for peer_id in player_ids:
		var assignment := {
			"peer_id": peer_id,
			"team": GameEnums.TeamSide.TEAM_A if peer_id in attacker_ids else GameEnums.TeamSide.TEAM_B,
			"role": -1,
			"passive": -1,
		}
		if peer_id in defender_ids:
			assignment["role"] = rng.randi_range(
				GameEnums.DefenderRole.PAPA,
				GameEnums.DefenderRole.BESTIA
			)
		else:
			assignment["passive"] = rng.randi_range(
				GameEnums.AttackerPassive.TANQUE,
				GameEnums.AttackerPassive.PORTA_PAPAS
			)
		assignments.append(assignment)

	return {"schema_version": 1, "players": assignments}

func to_json(assignments: Dictionary) -> String:
	if assignments.is_empty():
		return ""
	return JSON.stringify(assignments)

func from_json(json_text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY or not _valid_serialized_assignments(parsed):
		return {}
	var normalized: Dictionary = parsed.duplicate(true)
	normalized["schema_version"] = int(normalized["schema_version"])
	for player in normalized.players:
		for key in ["peer_id", "team", "role", "passive"]:
			player[key] = int(player[key])
	return normalized

func _valid_roster(
	player_ids: Array[int],
	attacker_ids: Array[int],
	defender_ids: Array[int]
) -> bool:
	if player_ids.size() != 6 or attacker_ids.size() != 3 or defender_ids.size() != 3:
		return false
	if player_ids.size() != player_ids.duplicate().size():
		return false
	return attacker_ids.all(func(peer_id: int) -> bool: return peer_id in player_ids) \
		and defender_ids.all(func(peer_id: int) -> bool: return peer_id in player_ids) \
		and attacker_ids.all(func(peer_id: int) -> bool: return peer_id not in defender_ids)

func _valid_serialized_assignments(data: Dictionary) -> bool:
	if data.get("schema_version", -1) != 1 or typeof(data.get("players")) != TYPE_ARRAY:
		return false
	if data.players.size() != 6:
		return false
	for player in data.players:
		if typeof(player) != TYPE_DICTIONARY:
			return false
		if typeof(player.get("peer_id")) != TYPE_FLOAT and typeof(player.get("peer_id")) != TYPE_INT:
			return false
		if typeof(player.get("team")) != TYPE_FLOAT and typeof(player.get("team")) != TYPE_INT:
			return false
		if typeof(player.get("role")) != TYPE_FLOAT and typeof(player.get("role")) != TYPE_INT:
			return false
		if typeof(player.get("passive")) != TYPE_FLOAT and typeof(player.get("passive")) != TYPE_INT:
			return false
	return true
