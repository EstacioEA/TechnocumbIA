class_name PapoiCookingEscape
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")

signal phase_changed(previous_phase: int, current_phase: int)
signal cooking_started(papa_id: int, carrier_id: int)
signal cooking_cancelled(papa_id: int)
signal cooking_completed(papa_id: int)
signal escape_reached(carrier_id: int)
signal transition_rejected(reason: String)

const COOKING_DURATION_SECONDS := 30.0
const PHASE_ACTIVE := 0
const PHASE_POT_COOKING := 1
const PHASE_ESCAPE := 2

var host_authority := false
var phase := PHASE_ACTIVE
var cooking_remaining := 0.0
var papa_id := -1
var carrier_id := -1
var papa_state := GameEnums.PapaState.FREE
var objective_text := "Captura a Papa y llévala a la olla."

var _capture_state: PapaCaptureState
var _beast_access: BeastAccessState

func _init(
	is_host: bool = false,
	capture_state: PapaCaptureState = null,
	beast_access: BeastAccessState = null
) -> void:
	host_authority = is_host
	_capture_state = capture_state
	_beast_access = beast_access

func start_cooking(is_inside_pot: bool) -> bool:
	if not _host_only():
		return _reject("Solo el host puede iniciar la cocción.")
	if phase != PHASE_ACTIVE:
		return _reject("La cocción solo puede iniciar desde ACTIVE.")
	if not is_inside_pot:
		return _reject("Papa debe estar dentro de la olla.")
	if _capture_state == null or _capture_state.papa_state != GameEnums.PapaState.CAPTURED:
		return _reject("La cocción requiere Papa capturada.")
	if _capture_state.carrier_id < 0:
		return _reject("La cocción requiere un portador válido.")
	papa_id = _capture_state.papa_id
	carrier_id = _capture_state.carrier_id
	papa_state = GameEnums.PapaState.BEING_COOKED
	cooking_remaining = COOKING_DURATION_SECONDS
	objective_text = "Protege la olla hasta completar la cocción."
	_set_phase(PHASE_POT_COOKING)
	if _beast_access != null and not _beast_access.set_pot_cooking(true):
		return _reject("No se pudo actualizar el acceso de Bestia.")
	cooking_started.emit(papa_id, carrier_id)
	return true

func rescue_by_beast() -> bool:
	if not _host_only():
		return _reject("Solo el host puede validar el rescate.")
	if phase != PHASE_POT_COOKING:
		return _reject("Bestia solo puede rescatar durante la cocción.")
	if _beast_access != null:
		if not _beast_access.appeared:
			return _reject("Bestia aún no ha aparecido.")
		if not _beast_access.can_enter_pot_room():
			return _reject("Bestia no tiene acceso autorizado a la sala de olla.")
	if _capture_state != null:
		if _capture_state.carrier_id < 0 or not _capture_state.request_drop(_capture_state.carrier_id):
			return _reject("No se pudo liberar Papa durante el rescate.")
	if _beast_access != null and not _beast_access.set_pot_cooking(false):
		return _reject("No se pudo cerrar el acceso de Bestia.")
	cooking_remaining = 0.0
	papa_state = GameEnums.PapaState.FREE
	objective_text = "Papa fue rescatada: vuelve a capturarla."
	_set_phase(PHASE_ACTIVE)
	cooking_cancelled.emit(papa_id)
	return true

func advance_host_clock(delta: float) -> bool:
	if not _host_only():
		return _reject("Solo el host puede avanzar la cocción.")
	if phase != PHASE_POT_COOKING or delta <= 0.0:
		return true
	cooking_remaining = maxf(0.0, cooking_remaining - delta)
	if is_zero_approx(cooking_remaining):
		_complete_cooking()
	return true

func reach_escape(position: Vector2, escape_zone: Rect2) -> bool:
	if not _host_only():
		return _reject("Solo el host puede validar el escape.")
	if phase != PHASE_ESCAPE:
		return _reject("El escape solo está disponible tras completar la cocción.")
	if not escape_zone.has_point(position):
		return _reject("El atacante aún no está en la base atacante.")
	objective_text = "Escape atacante alcanzado."
	escape_reached.emit(carrier_id)
	return true

func get_snapshot() -> Dictionary:
	return {
		"phase": phase,
		"cooking_remaining": cooking_remaining,
		"papa_id": papa_id,
		"carrier_id": carrier_id,
		"papa_state": papa_state,
		"objective_text": objective_text,
	}

func _complete_cooking() -> void:
	if phase != PHASE_POT_COOKING:
		return
	if _beast_access != null:
		_beast_access.set_pot_cooking(false)
	cooking_remaining = 0.0
	papa_state = GameEnums.PapaState.COOKED
	objective_text = "Papa cocida: regresa a la base atacante."
	_set_phase(PHASE_ESCAPE)
	cooking_completed.emit(papa_id)

func _set_phase(next_phase: int) -> void:
	var previous := phase
	phase = next_phase
	phase_changed.emit(previous, next_phase)

func _reject(reason: String) -> bool:
	transition_rejected.emit(reason)
	return false

func _host_only() -> bool:
	return host_authority
