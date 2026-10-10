extends SceneTree

const FEEDBACK_SCENE := preload("res://scenes/ui/role_feedback.tscn")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var feedback := FEEDBACK_SCENE.instantiate()
	root.add_child(feedback)
	await process_frame
	feedback.present_event("IMPACT", "Golpe confirmado por el host.", "REAL")
	await process_frame
	_check(feedback.get_event_type() == "IMPACT", "impact event is stored")
	_check(feedback.get_source_kind() == "REAL", "real source is labeled")
	_check(feedback.get_node("EventPanel/EventLayout/EventText/Event").text == "IMPACTO RECIBIDO", "impact label is visible")
	_check(feedback.get_node("EventPanel/EventLayout/EventText/Source").text == "FUENTE: REAL · SEÑAL RECIBIDA", "real signal label is visible")

	feedback.present_event("DISCONNECT", "Jugador 4 salió de la sesión.", "SIMULATED")
	await process_frame
	_check(feedback.get_event_type() == "DISCONNECT", "disconnect event is stored")
	_check(feedback.get_node("EventPanel/EventLayout/EventText/Event").text == "DESCONEXIÓN RECIBIDA", "disconnect is distinct from victory")
	_check(feedback.get_node("EventPanel/EventLayout/EventText/Source").text == "FUENTE: SIMULADA · PREVIEW", "simulated source is labeled")
	var panel := feedback.get_node("EventPanel") as PanelContainer
	_check(panel.position.y == 24.0, "feedback stays below the top edge")
	_check(panel.size.x <= 360.0 and panel.size.y <= 128.0, "feedback stays in a compact corner panel")
	_check(not feedback.has_method("_process"), "feedback does not animate or calculate gameplay")

	if _failures.is_empty():
		print("GM04_ROLE_FEEDBACK_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GM04_ROLE_FEEDBACK_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
