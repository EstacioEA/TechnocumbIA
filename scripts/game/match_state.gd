extends RefCounted
class_name MatchState

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const SCHEMA_VERSION := 1

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
	result.schema_version = data.schema_version
	result.revision = data.revision
	result.phase = data.phase
	result.players.assign(data.players)
	result.scores = data.scores.duplicate(true)
	result.round_number = data.round_number
	result.attacking_team = data.attacking_team
	result.round_time_remaining = data.round_time_remaining
	result.phase_time_remaining = data.phase_time_remaining
	result.papa_state = data.papa_state
	result.round_winner = data.round_winner
	result.round_end_reason = data.round_end_reason
	result.match_winner = data.match_winner
	return result


static func from_json(json_text: String) -> MatchState:
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return from_dictionary(parsed)


static func _has_valid_schema(data: Dictionary) -> bool:
	var required := [
		"schema_version", "revision", "phase", "players", "scores", "round_number",
		"attacking_team", "round_time_remaining", "phase_time_remaining", "papa_state",
		"round_winner", "round_end_reason", "match_winner",
	]
	for key in required:
		if not data.has(key):
			return false
	if typeof(data.schema_version) != TYPE_INT or data.schema_version != SCHEMA_VERSION:
		return false
	if typeof(data.revision) != TYPE_INT or data.revision < 0:
		return false
	if typeof(data.phase) != TYPE_INT or data.phase < GameEnums.GamePhase.LOBBY or data.phase > GameEnums.GamePhase.MATCH_RESULT:
		return false
	if typeof(data.players) != TYPE_ARRAY or typeof(data.scores) != TYPE_DICTIONARY:
		return false
	if typeof(data.round_number) != TYPE_INT or data.round_number < 0 or data.round_number > 5:
		return false
	if typeof(data.attacking_team) != TYPE_INT or not _is_team(data.attacking_team):
		return false
	if typeof(data.round_time_remaining) != TYPE_FLOAT and typeof(data.round_time_remaining) != TYPE_INT:
		return false
	if typeof(data.phase_time_remaining) != TYPE_FLOAT and typeof(data.phase_time_remaining) != TYPE_INT:
		return false
	if data.round_time_remaining < 0.0 or data.phase_time_remaining < 0.0:
		return false
	if typeof(data.papa_state) != TYPE_INT or data.papa_state < GameEnums.PapaState.FREE or data.papa_state > GameEnums.PapaState.COOKED:
		return false
	if typeof(data.round_winner) != TYPE_INT or (data.round_winner != -1 and not _is_team(data.round_winner)):
		return false
	if typeof(data.round_end_reason) != TYPE_INT or (data.round_end_reason != -1 and (data.round_end_reason < GameEnums.RoundEndReason.ESCAPE_SUCCESS or data.round_end_reason > GameEnums.RoundEndReason.DISCONNECT)):
		return false
	if typeof(data.match_winner) != TYPE_INT or (data.match_winner != -1 and not _is_team(data.match_winner)):
		return false
	if data.scores.size() != 2 or not data.scores.has("TEAM_A") or not data.scores.has("TEAM_B"):
		return false
	for score in data.scores.values():
		if typeof(score) != TYPE_INT or score < 0 or score > 3:
			return false
	for player in data.players:
		if typeof(player) != TYPE_DICTIONARY or not player.has("peer_id"):
			return false
		if typeof(player.peer_id) != TYPE_INT or player.peer_id <= 0:
			return false
		if player.has("team") and (typeof(player.team) != TYPE_INT or not _is_team(player.team)):
			return false
		if player.has("role") and typeof(player.role) != TYPE_INT:
			return false
		if player.has("passive") and typeof(player.passive) != TYPE_INT:
			return false
		if player.has("lives") and (typeof(player.lives) != TYPE_INT or player.lives < 0):
			return false
	return true


static func team_score_key(team: int) -> String:
	if team == GameEnums.TeamSide.TEAM_A:
		return "TEAM_A"
	if team == GameEnums.TeamSide.TEAM_B:
		return "TEAM_B"
	return ""


static func _is_team(team: int) -> bool:
	return team == GameEnums.TeamSide.TEAM_A or team == GameEnums.TeamSide.TEAM_B
