extends SceneTree

const LobbyScene = preload("res://scenes/lobby/lobby.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var lobby: Control = LobbyScene.instantiate()
	root.add_child(lobby)
	await process_frame

	var slots: Array = lobby.get("_slot_labels")
	_check(slots.size() == 6, "shows six fixed lobby slots")
	_check(str(slots[0].text).contains("VACANTE"), "empty slot is labeled vacant")
	_check(str(lobby.get("_roster_count_label").text).contains("SIN CONEXIÓN"), "initial lobby shows disconnected state")

	var partial: Array[Dictionary] = [{"id": 1, "name": "Host", "ready": false}]
	lobby.call("_on_lobby_updated", partial)
	_check(str(slots[0].text).contains("HOST · ID 1"), "host role and id are visible")
	_check(str(slots[0].text).contains("ESPERANDO"), "not-ready state is visible with text")
	_check(str(slots[1].text).contains("VACANTE"), "partial lobby retains vacant slots")
	_check(str(lobby.get("_roster_count_label").text).contains("1 / 6"), "partial lobby count is visible")

	var full: Array[Dictionary] = []
	for peer_id in range(1, 7):
		full.append({"id": peer_id, "name": "Jugador %d" % peer_id, "ready": peer_id == 1})
	lobby.call("_on_lobby_updated", full)
	_check(str(slots[0].text).contains("LISTO"), "ready state is visible with text")
	_check(str(slots[5].text).contains("CLIENTE · ID 6"), "client id is visible")
	_check(str(lobby.get("_roster_count_label").text).contains("6 / 6"), "full lobby count is visible")
	_check(lobby.get("_start_button").disabled, "start remains disabled without an authoritative full ready network session")

	if _failures == 0:
		print("lobby_presentation_test: PASS")
		quit(0)
	else:
		printerr("lobby_presentation_test: %d failure(s)" % _failures)
		quit(1)


var _failures := 0


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		_failures += 1
		printerr("FAIL: %s" % description)
