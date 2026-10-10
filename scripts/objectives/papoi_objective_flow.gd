class_name PapoiObjectiveFlow
extends Node

const GameEnums = preload("res://scripts/shared/game_enums.gd")

signal state_changed(snapshot: Dictionary)
signal transition_rejected(reason: String)
signal papa_zone_state_changed(papa_id: int, is_valid: bool)

enum Phase {
	ACTIVE,
	POT_COOKING,
	ESCAPE,
	ROUND_RESULT,
	MATCH_RESULT,
}

const COOKING_DURATION_SECONDS := 30.0

var phase: Phase = Phase.ACTIVE
var round_number := 1
var round_time_remaining := 420.0
var cooking_time_remaining := 0.0
var score := {"attackers": 0, "defenders": 0}
var papa_id := -1
var papa_in_pot := false
var cooking_started_by_host := false
var pot_rescued := false
var objective_text := "Captura a Papa y llévala a la olla."

func advance_host_clock(delta: float, host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("Solo el host puede avanzar el reloj autoritativo.")
	if phase == Phase.ACTIVE or phase == Phase.POT_COOKING or phase == Phase.ESCAPE:
		round_time_remaining = maxf(0.0, round_time_remaining - delta)
	if phase == Phase.POT_COOKING:
		cooking_time_remaining = maxf(0.0, cooking_time_remaining - delta)
		if is_zero_approx(cooking_time_remaining):
			_complete_cooking(true)
	_emit_state()
	return true

func set_papa_in_pot(candidate_papa_id: int, is_valid: bool, host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("Solo el host puede actualizar la detección de Papa.")
	if phase != Phase.ACTIVE:
		return _reject("La olla solo acepta Papa durante una ronda activa.")
	papa_id = candidate_papa_id
	papa_in_pot = is_valid
	_emit_state()
	return true

func detect_papa_in_pot(
	candidate_papa_id: int,
	papa_state: int,
	is_inside_zone: bool,
	host_authorized: bool
) -> bool:
	if not host_authorized:
		return _reject("Solo el host puede validar Papa dentro de la olla.")
	if candidate_papa_id < 0:
		return _reject("La Papa requiere un identificador válido.")
	if phase != Phase.ACTIVE:
		return _reject("La olla solo acepta Papa durante una ronda activa.")
	var is_valid := (
		is_inside_zone
		and papa_state == GameEnums.PapaState.CAPTURED
	)
	papa_id = candidate_papa_id
	papa_in_pot = is_valid
	papa_zone_state_changed.emit(papa_id, papa_in_pot)
	_emit_state()
	return is_valid

func start_cooking(host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("El inicio de cocción requiere autorización del host.")
	if phase != Phase.ACTIVE or not papa_in_pot or papa_id < 0:
		return _reject("La cocción requiere una Papa válida dentro de la olla.")
	phase = Phase.POT_COOKING
	cooking_started_by_host = true
	cooking_time_remaining = COOKING_DURATION_SECONDS
	objective_text = "Protege la olla hasta completar la cocción."
	_emit_state()
	return true

func rescue_by_beast(host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("El rescate requiere validación del host.")
	if phase != Phase.POT_COOKING:
		return _reject("Bestia solo puede rescatar durante la cocción.")
	phase = Phase.ACTIVE
	papa_in_pot = false
	cooking_started_by_host = false
	pot_rescued = true
	cooking_time_remaining = 0.0
	objective_text = "Papa fue rescatada: vuelve a capturarla."
	_emit_state()
	return true

func mark_escape_reached(host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("El escape requiere validación del host.")
	if phase != Phase.ESCAPE:
		return _reject("El escape solo está disponible tras completar la cocción.")
	phase = Phase.ROUND_RESULT
	objective_text = "Ronda completada por escape atacante."
	_emit_state()
	return true

func apply_cooking_result(host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("La transición requiere autorización del host.")
	if phase != Phase.POT_COOKING or cooking_time_remaining > 0.0:
		return _reject("La cocción aún no ha terminado.")
	_complete_cooking(false)
	return true

func get_snapshot() -> Dictionary:
	return {
		"phase": Phase.keys()[phase],
		"round": round_number,
		"round_time_remaining": round_time_remaining,
		"cooking_time_remaining": cooking_time_remaining,
		"score": score.duplicate(),
		"papa_in_pot": papa_in_pot,
		"objective_text": objective_text,
		"pot_rescued": pot_rescued,
	}

func _complete_cooking(from_timer: bool) -> void:
	if phase != Phase.POT_COOKING:
		return
	phase = Phase.ESCAPE
	cooking_time_remaining = 0.0
	papa_in_pot = true
	objective_text = "¡Papa cocida! Regresa a la base atacante."
	_emit_state()

func _reject(reason: String) -> bool:
	transition_rejected.emit(reason)
	return false

func _emit_state() -> void:
	state_changed.emit(get_snapshot())
