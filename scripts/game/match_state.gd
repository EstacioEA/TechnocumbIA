extends RefCounted
class_name MatchState

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const SCHEMA_VERSION := 2

var schema_version: int = SCHEMA_VERSION
var revision: int = 0
var phase: int = GameEnums.GamePhase.LOBBY
var players: Array[Dictionary] = []
var scores: Dictionary = {
	"TEAM_A": 0,
	"TEAM_B": 0,
}
var round_number: int = 0
var attacking_team: int = GameEnums.TeamSide.TEAM_A
var round_time_remaining: float = 0.0
var phase_time_remaining: float = 0.0
var papa_state: int = GameEnums.PapaState.FREE
var escape_available: bool = false
var round_winner: int = -1
var round_end_reason: int = -1
var match_winner: int = -1


func to_dictionary() -> Dictionary:
	return {
		"schema_version": schema_version,
		"revision": revision,
		"phase": phase,
		"players": players.duplicate(true),
		"scores": scores.duplicate(true),
		"round_number": round_number,
		"attacking_team": attacking_team,
		"round_time_remaining": round_time_remaining,
		"phase_time_remaining": phase_time_remaining,
		"papa_state": papa_state,
		"escape_available": escape_available,
		"round_winner": round_winner,
		"round_end_reason": round_end_reason,
		"match_winner": match_winner,
	}


func to_json() -> String:
	return JSON.stringify(to_dictionary())


static func from_dictionary(data: Dictionary) -> MatchState:
	if not _has_valid_schema(data):
		return null
	var result := MatchState.new()
	result.schema_version = int(data.schema_version)
	result.revision = int(data.revision)
	result.phase = int(data.phase)
	for player in data.players:
		var normalized_player: Dictionary = player.duplicate(true)
		for key in ["peer_id", "team", "role", "passive", "lives"]:
			if normalized_player.has(key):
				normalized_player[key] = int(normalized_player[key])
		result.players.append(normalized_player)
	result.scores = {
		"TEAM_A": int(data.scores["TEAM_A"]),
		"TEAM_B": int(data.scores["TEAM_B"]),
	}
	result.round_number = int(data.round_number)
	result.attacking_team = int(data.attacking_team)
	result.round_time_remaining = float(data.round_time_remaining)
	result.phase_time_remaining = float(data.phase_time_remaining)
	result.papa_state = int(data.papa_state)
	result.escape_available = data.escape_available
	result.round_winner = int(data.round_winner)
	result.round_end_reason = int(data.round_end_reason)
	result.match_winner = int(data.match_winner)
	return result


static func from_json(json_text: String) -> MatchState:
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	var normalized: Variant = _normalize_json_numbers(parsed)
	if normalized == null:
		return null
	return from_dictionary(normalized)


static func _normalize_json_numbers(data: Dictionary) -> Variant:
	var normalized: Dictionary = data.duplicate(true)
	var integer_fields := [
		"schema_version", "revision", "phase", "round_number", "attacking_team",
		"papa_state", "round_winner", "round_end_reason", "match_winner",
	]
	for field: String in integer_fields:
		if not normalized.has(field):
			continue
		var integer_value: Variant = _as_json_integer(normalized[field])
		if integer_value == null:
			return null
		normalized[field] = integer_value

	if normalized.get("scores") is Dictionary:
		var normalized_scores: Dictionary = normalized["scores"]
		for team_key: Variant in normalized_scores.keys():
			var score_value: Variant = _as_json_integer(normalized_scores[team_key])
			if score_value == null:
				return null
			normalized_scores[team_key] = score_value

	if normalized.get("players") is Array:
		var normalized_players: Array = []
		for player: Variant in normalized["players"]:
			if not player is Dictionary:
				return null
			var normalized_player: Dictionary = player.duplicate(true)
			for field: String in ["peer_id", "team", "role", "passive", "lives"]:
				if not normalized_player.has(field):
					continue
				var integer_value: Variant = _as_json_integer(normalized_player[field])
				if integer_value == null:
					return null
				normalized_player[field] = integer_value
			normalized_players.append(normalized_player)
		normalized["players"] = normalized_players
	return normalized


static func _as_json_integer(value: Variant) -> Variant:
	if typeof(value) == TYPE_INT:
		return value
	if typeof(value) != TYPE_FLOAT or not is_equal_approx(value, round(value)):
		return null
	return int(value)


static func _has_valid_schema(data: Dictionary) -> bool:
	var required := [
		"schema_version", "revision", "phase", "players", "scores", "round_number",
		"attacking_team", "round_time_remaining", "phase_time_remaining", "papa_state",
		"escape_available", "round_winner", "round_end_reason", "match_winner",
	]
	for key in required:
		if not data.has(key):
			return false
	if not _is_integer_number(data.schema_version) or data.schema_version != SCHEMA_VERSION:
		return false
	if not _is_integer_number(data.revision) or data.revision < 0:
		return false
	if not _is_integer_number(data.phase) or data.phase < GameEnums.GamePhase.LOBBY or data.phase > GameEnums.GamePhase.MATCH_RESULT:
		return false
	if typeof(data.players) != TYPE_ARRAY or typeof(data.scores) != TYPE_DICTIONARY:
		return false
	if not _is_integer_number(data.round_number) or data.round_number < 0 or data.round_number > 5:
		return false
	if not _is_integer_number(data.attacking_team) or not _is_team(int(data.attacking_team)):
		return false
	if typeof(data.round_time_remaining) != TYPE_FLOAT and typeof(data.round_time_remaining) != TYPE_INT:
		return false
	if typeof(data.phase_time_remaining) != TYPE_FLOAT and typeof(data.phase_time_remaining) != TYPE_INT:
		return false
	if data.round_time_remaining < 0.0 or data.phase_time_remaining < 0.0:
		return false
	if not _is_integer_number(data.papa_state) or data.papa_state < GameEnums.PapaState.FREE or data.papa_state > GameEnums.PapaState.COOKED:
		return false
	if typeof(data.escape_available) != TYPE_BOOL:
		return false
	if not _is_integer_number(data.round_winner) or (data.round_winner != -1 and not _is_team(int(data.round_winner))):
		return false
	if not _is_integer_number(data.round_end_reason) or (data.round_end_reason != -1 and (data.round_end_reason < GameEnums.RoundEndReason.ESCAPE_SUCCESS or data.round_end_reason > GameEnums.RoundEndReason.DISCONNECT)):
		return false
	if not _is_integer_number(data.match_winner) or (data.match_winner != -1 and not _is_team(int(data.match_winner))):
		return false
	if data.scores.size() != 2 or not data.scores.has("TEAM_A") or not data.scores.has("TEAM_B"):
		return false
	for score in data.scores.values():
		if not _is_integer_number(score) or score < 0 or score > 3:
			return false
	for player in data.players:
		if typeof(player) != TYPE_DICTIONARY or not player.has("peer_id"):
			return false
		if not _is_integer_number(player.peer_id) or player.peer_id <= 0:
			return false
		if player.has("team") and (not _is_integer_number(player.team) or not _is_team(int(player.team))):
			return false
		if player.has("role") and not _is_integer_number(player.role):
			return false
		if player.has("passive") and not _is_integer_number(player.passive):
			return false
		if player.has("lives") and (not _is_integer_number(player.lives) or player.lives < 0):
			return false
	return true


static func team_score_key(team: int) -> String:
	if team == GameEnums.TeamSide.TEAM_A:
		return "TEAM_A"
	if team == GameEnums.TeamSide.TEAM_B:
		return "TEAM_B"
	return ""


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) != TYPE_FLOAT:
		return false
	var numeric := float(value)
	return is_finite(numeric) and floorf(numeric) == numeric


static func _is_team(team: int) -> bool:
	return team == GameEnums.TeamSide.TEAM_A or team == GameEnums.TeamSide.TEAM_B
