extends SceneTree

const FEEDBACK_SCENE := preload("res://scenes/ui/cooldown_feedback.tscn")

var _failures: Array[String] = []

func _init() -> void:
	call_deferred("run")

func run() -> void:
	var feedback := FEEDBACK_SCENE.instantiate()
	root.add_child(feedback)
	await process_frame
	feedback.set_cooldown_state("dash", "READY")
	feedback.set_cooldown_state("special", "BLOCKED", "NO DISPONIBLE")
	feedback.set_cooldown_state("sprint", "COUNTDOWN", "1.5s RECIBIDOS")
	await process_frame
	_check(feedback.get_node("CooldownSlots/dash/State").text == "DISPONIBLE", "ready state is visible")
	_check(feedback.get_node("CooldownSlots/special/State").text == "BLOQUEADO", "blocked state is visible")
	_check(feedback.get_node("CooldownSlots/sprint/State").text == "CUENTA RECIBIDA", "countdown state is visible")
	_check(feedback.get_node("CooldownSlots/sprint/Time").text == "1.5s RECIBIDOS", "received time is presented unchanged")
	_check(not feedback.has_method("_process"), "component does not calculate cooldowns every frame")

	if _failures.is_empty():
		print("GM02_COOLDOWN_FEEDBACK_TEST: PASS")
		quit(0)
		return
	for failure in _failures:
		push_error("GM02_COOLDOWN_FEEDBACK_TEST: %s" % failure)
	quit(1)

func _check(condition: bool, label: String) -> void:
	if not condition:
		_failures.append(label)
