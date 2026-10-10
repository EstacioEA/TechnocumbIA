class_name AbilitiesEnrageState
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")

const TRAP_COOLDOWN_SECONDS := 8.0
const TRAP_DURATION_SECONDS := 5.0
const TANK_TRAP_DAMAGE_MULTIPLIER := 0.5
const HUNTER_BEAST_DAMAGE_MULTIPLIER := 1.25
const PORTA_PAPAS_SPRINT_REDUCTION_SECONDS := 2.0
const ENRAGED_COOLDOWN_MULTIPLIER := 0.5
const ENRAGED_SPEED_MULTIPLIER := 1.25

const ACTION_TRAP := &"trollazzo_trap"

var host_authority := false
var role_by_player: Dictionary = {}
var passive_by_player: Dictionary = {}
var beast_id := -1
var trap_cooldown_remaining := 0.0
var traps: Array[Dictionary] = []
var beast_enraged := false
var beast_speed_multiplier := 1.0

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func configure_round(
	roles: Dictionary,
	passives: Dictionary,
	configured_beast_id: int
) -> bool:
	if not _host_only() or configured_beast_id <= 0:
		return false
	role_by_player = roles.duplicate(true)
	passive_by_player = passives.duplicate(true)
	beast_id = configured_beast_id
	trap_cooldown_remaining = 0.0
	traps.clear()
	beast_enraged = false
	beast_speed_multiplier = 1.0
	return true

func tick(delta: float) -> void:
	if not _host_only() or delta <= 0.0:
		return
	trap_cooldown_remaining = maxf(0.0, trap_cooldown_remaining - delta)
	for trap in traps:
		if trap["active"]:
			trap["remaining"] = maxf(0.0, float(trap["remaining"]) - delta)
			if trap["remaining"] <= 0.0:
				trap["active"] = false

func request_trollazzo_trap(owner_id: int, position: Vector2) -> bool:
	if not _host_only() or role_by_player.get(owner_id, -1) != GameEnums.DefenderRole.TROLAZZO:
		return false
	if trap_cooldown_remaining > 0.0:
		return false
	trap_cooldown_remaining = TRAP_COOLDOWN_SECONDS
	traps.append({
		"owner_id": owner_id,
		"position": position,
		"active": true,
		"remaining": TRAP_DURATION_SECONDS,
	})
	return true

func get_trap_damage_multiplier(player_id: int) -> float:
	if passive_by_player.get(player_id, -1) == GameEnums.AttackerPassive.TANQUE:
		return TANK_TRAP_DAMAGE_MULTIPLIER
	return 1.0

func get_beast_damage_multiplier(player_id: int) -> float:
	if passive_by_player.get(player_id, -1) == GameEnums.AttackerPassive.CAZADOR:
		return HUNTER_BEAST_DAMAGE_MULTIPLIER
	return 1.0

func get_porta_papas_sprint_reduction(player_id: int) -> float:
	if passive_by_player.get(player_id, -1) == GameEnums.AttackerPassive.PORTA_PAPAS:
		return PORTA_PAPAS_SPRINT_REDUCTION_SECONDS
	return 0.0

func request_cooking_completed() -> bool:
	if not _host_only() or beast_id <= 0:
		return false
	beast_enraged = true
	beast_speed_multiplier = ENRAGED_SPEED_MULTIPLIER
	return true

func get_beast_cooldown(base_cooldown: float) -> float:
	if base_cooldown < 0.0:
		return 0.0
	if not beast_enraged:
		return base_cooldown
	return maxf(0.0, base_cooldown * ENRAGED_COOLDOWN_MULTIPLIER)

func get_snapshot() -> Dictionary:
	return {
		"trap_cooldown_remaining": trap_cooldown_remaining,
		"traps": traps.duplicate(true),
		"beast_enraged": beast_enraged,
		"beast_speed_multiplier": beast_speed_multiplier,
		"beast_cooldown_multiplier": ENRAGED_COOLDOWN_MULTIPLIER if beast_enraged else 1.0,
	}

func _host_only() -> bool:
	return host_authority
