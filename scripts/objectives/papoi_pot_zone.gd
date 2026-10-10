class_name PapoiPotZone
extends Node

signal papa_validation_changed(papa_id: int, is_valid: bool)
signal validation_rejected(reason: String)

const GameEnums = preload("res://scripts/shared/game_enums.gd")

var papa_id := -1
var papa_is_valid := false

func evaluate_papa(
	candidate_papa_id: int,
	papa_state: int,
	is_inside_zone: bool,
	host_authorized: bool
) -> bool:
	if not host_authorized:
		return _reject("Solo el host puede validar Papa dentro de la olla.")
	if candidate_papa_id < 0:
		return _reject("La Papa requiere un identificador válido.")
	papa_id = candidate_papa_id
	papa_is_valid = (
		is_inside_zone
		and papa_state == GameEnums.PapaState.CAPTURED
	)
	papa_validation_changed.emit(papa_id, papa_is_valid)
	return papa_is_valid

func clear(host_authorized: bool) -> bool:
	if not host_authorized:
		return _reject("Solo el host puede limpiar el estado de la olla.")
	papa_id = -1
	papa_is_valid = false
	papa_validation_changed.emit(papa_id, false)
	return true

func is_valid() -> bool:
	return papa_is_valid

func _reject(reason: String) -> bool:
	validation_rejected.emit(reason)
	return false
