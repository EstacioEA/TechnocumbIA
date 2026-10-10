extends SceneTree

const FEEDBACK_SCENE := preload("res://scenes/ui/papa_objective_feedback.tscn")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var feedback := FEEDBACK_SCENE.instantiate()
	root.add_child(feedback)
	await process_frame
	var states := [
		{"state": "CAPTURED", "label": "PAPA CAPTURADA"},
		{"state": "TRANSPORTING", "label": "PAPA TRANSPORTADA"},
		{"state": "COOKING", "label": "PAPA EN OLLA · COCINÁNDOSE"},
		{"state": "RESCUED", "label": "PAPA RESCATADA"},
		{"state": "ESCAPED", "label": "PAPA ESCAPADA"},
	]
	for state_data in states:
		feedback.set_objective_state(state_data.state, "EVENTO RECIBIDO")
		await process_frame
		_check(feedback.get_state() == state_data.state, "%s state is stored" % state_data.state)
		_check(feedback.get_node("PapaFeedbackLayout/State").text == state_data.label, "%s label is visible" % state_data.state)
		_check(feedback.get_node("PapaFeedbackLayout/PapaIcon").texture != null, "%s icon is loaded" % state_data.state)
		_check(feedback.get_node("PapaFeedbackLayout/Detail").text == "EVENTO RECIBIDO", "%s detail is presented" % state_data.state)

	if _failures.is_empty():
		print("GM03_PAPA_FEEDBACK_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GM03_PAPA_FEEDBACK_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
