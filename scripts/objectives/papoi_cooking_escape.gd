class_name PapoiCookingEscape
extends RefCounted

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const PapaCaptureStateData = preload("res://scripts/combat/papa_capture_state.gd")
const BeastAccessStateData = preload("res://scripts/combat/beast_access_state.gd")

signal phase_changed(previous_phase: int, current_phase: int)
signal cooking_started(papa_id: int, carrier_id: int)
signal cooking_cancelled(papa_id: int)
signal cooking_completed(papa_id: int)
signal escape_reached(carrier_id: int)
signal transition_rejected(reason: String)

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
var escape_available := false

var _capture_state: RefCounted
var _beast_access: RefCounted

func _init(
	is_host: bool = false,
	capture_state: RefCounted = null,
	beast_access: RefCounted = null
) -> void:
	host_authority = is_host
	_capture_state = capture_state
	_beast_access = beast_access

func start_cooking(is_inside_pot: bool) -> bool:
	if not _host_only():
		return _reject("Solo el host puede iniciar la cocción.")
	if phase != PHASE_POT_COOKING:
		return _reject("GameState debe confirmar POT_COOKING antes de iniciar el objetivo.")
	if not is_inside_pot:
		return _reject("Papa debe estar dentro de la olla.")
	if _capture_state == null or _capture_state.papa_state != GameEnums.PapaState.CAPTURED:
		return _reject("La cocción requiere Papa capturada.")
	if _capture_state.carrier_id < 0:
		return _reject("La cocción requiere un portador válido.")
	papa_id = _capture_state.papa_id
	carrier_id = _capture_state.carrier_id
	papa_state = GameEnums.PapaState.BEING_COOKED
	escape_available = false
	objective_text = "Protege la olla hasta completar la cocción."
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
	escape_available = false
	papa_state = GameEnums.PapaState.FREE
	objective_text = "Papa fue rescatada: vuelve a capturarla."
	return true

func apply_authoritative_state(snapshot: Dictionary) -> void:
	var game_phase := int(snapshot.get("phase", GameEnums.GamePhase.LOBBY))
	var previous_phase := phase
	match game_phase:
		GameEnums.GamePhase.POT_COOKING:
			phase = PHASE_POT_COOKING
		GameEnums.GamePhase.ESCAPE:
			phase = PHASE_ESCAPE
		_:
			phase = PHASE_ACTIVE
	var phase_did_change := phase != previous_phase
	var next_papa_state := int(snapshot.get("papa_state", GameEnums.PapaState.FREE))
	if GameEnums.PapaState.values().has(next_papa_state):
		papa_state = next_papa_state
	cooking_remaining = maxf(0.0, float(snapshot.get("phase_time_remaining", 0.0))) \
		if phase == PHASE_POT_COOKING else 0.0
	escape_available = bool(snapshot.get("escape_available", false))
	if phase == PHASE_ESCAPE:
		objective_text = "Papa cocida: regresa a la base atacante."
		if previous_phase == PHASE_POT_COOKING:
			if _beast_access != null:
				_beast_access.set_pot_cooking(false)
			cooking_completed.emit(papa_id)
	elif phase == PHASE_POT_COOKING:
		objective_text = "Protege la olla hasta completar la cocción."
	elif previous_phase == PHASE_POT_COOKING and game_phase == GameEnums.GamePhase.ACTIVE:
		cooking_remaining = 0.0
		objective_text = "Papa fue rescatada: vuelve a capturarla."
		cooking_cancelled.emit(papa_id)
	elif previous_phase == PHASE_POT_COOKING:
		cooking_remaining = 0.0
		objective_text = "La ronda terminó."
	if phase_did_change:
		phase_changed.emit(previous_phase, phase)

func reach_escape(position: Vector2, escape_zone: Rect2) -> bool:
	if not _host_only():
		return _reject("Solo el host puede validar el escape.")
	if phase != PHASE_ESCAPE or not escape_available:
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
		"escape_available": escape_available,
		"objective_text": objective_text,
	}

func _reject(reason: String) -> bool:
	transition_rejected.emit(reason)
	return false

func _host_only() -> bool:
	return host_authority
