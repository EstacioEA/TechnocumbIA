class_name PapaCaptureState
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")

const IMMOBILIZATION_SECONDS := 20.0
const DROP_STUN_SECONDS := 3.0
const PASSIVE_PORTA_PAPAS := GameEnums.AttackerPassive.PORTA_PAPAS

var host_authority := false
var papa_id := -1
var carrier_id := -1
var immobilized_remaining := 0.0
var papa_state := GameEnums.PapaState.FREE
var attacker_ids: Array[int] = []
var porta_papas_ids: Array[int] = []
var carrier_stun_remaining := 0.0
var stunned_player_id := -1

func _init(is_host: bool = false) -> void:
	host_authority = is_host

func configure_round(
	papa_player_id: int,
	attacker_player_ids: Array[int],
	porta_papas_player_ids: Array[int]
) -> bool:
	if not host_authority or papa_player_id <= 0 or attacker_player_ids.is_empty():
		return false
	papa_id = papa_player_id
	attacker_ids = attacker_player_ids.duplicate()
	porta_papas_ids = porta_papas_player_ids.duplicate()
	carrier_id = -1
	immobilized_remaining = 0.0
	carrier_stun_remaining = 0.0
	stunned_player_id = -1
	papa_state = GameEnums.PapaState.FREE
	return true

func tick(delta: float) -> void:
	if not host_authority or delta <= 0.0:
		return
	immobilized_remaining = maxf(0.0, immobilized_remaining - delta)
	carrier_stun_remaining = maxf(0.0, carrier_stun_remaining - delta)
	if carrier_stun_remaining == 0.0:
		stunned_player_id = -1

func request_capture(actor_id: int) -> bool:
	if not _host_only() or actor_id not in attacker_ids:
		return false
	if actor_id == stunned_player_id and carrier_stun_remaining > 0.0:
		return false
	if carrier_id != -1 or papa_state != GameEnums.PapaState.FREE:
		return false
	if immobilized_remaining > 0.0:
		return false
	carrier_id = actor_id
	papa_state = GameEnums.PapaState.CAPTURED
	immobilized_remaining = IMMOBILIZATION_SECONDS
	return true

func request_porta_papas_sprint(actor_id: int) -> bool:
	if not _host_only() or actor_id != carrier_id:
		return false
	if actor_id not in porta_papas_ids:
		return false
	immobilized_remaining = maxf(0.0, immobilized_remaining - _sprint_reduction())
	return true

func request_drop(actor_id: int) -> bool:
	if not _host_only() or actor_id != carrier_id:
		return false
	_release_papa()
	stunned_player_id = actor_id
	carrier_stun_remaining = DROP_STUN_SECONDS
	return true

func request_hit_carrier(actor_id: int) -> bool:
	if not _host_only() or actor_id != carrier_id:
		return false
	_release_papa()
	stunned_player_id = actor_id
	carrier_stun_remaining = DROP_STUN_SECONDS
	return true

func is_papa_immobilized() -> bool:
	return immobilized_remaining > 0.0

func get_snapshot() -> Dictionary:
	return {
		"papa_id": papa_id,
		"carrier_id": carrier_id,
		"papa_state": papa_state,
		"immobilized_remaining": immobilized_remaining,
		"carrier_stun_remaining": carrier_stun_remaining,
	}

func _release_papa() -> void:
	carrier_id = -1
	papa_state = GameEnums.PapaState.FREE
	immobilized_remaining = 0.0

func _sprint_reduction() -> float:
	# Balance is intentionally explicit until the team freezes sprint tuning.
	return 2.0

func _host_only() -> bool:
	return host_authority
