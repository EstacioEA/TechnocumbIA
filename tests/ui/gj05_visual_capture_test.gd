extends SceneTree

const MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")
const EVIDENCE_ROOT := "res://docs/handoffs/evidence/gj05"

var _failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var resolutions := [Vector2i(1280, 720), Vector2i(1600, 900)]
	for resolution_index in range(resolutions.size()):
		var resolution: Vector2i = resolutions[resolution_index]
		root.size = resolution
		var resolution_name := "%dx%d" % [resolution.x, resolution.y]
		var evidence_dir := ProjectSettings.globalize_path(EVIDENCE_ROOT.path_join(resolution_name))
		DirAccess.make_dir_recursive_absolute(evidence_dir)
		await _run_resolution(resolution_index, resolution, evidence_dir)

	if _failures == 0:
		print("gj05_visual_capture_test: PASS")
		quit(0)
	else:
		printerr("gj05_visual_capture_test: %d failure(s)" % _failures)
		quit(1)


func _run_resolution(resolution_index: int, resolution: Vector2i, evidence_dir: String) -> void:
	var menu: Control = MENU_SCENE.instantiate()
	root.add_child(menu)
	await process_frame
	await process_frame
	_check(menu.get_node("%HostButton").focus_mode == Control.FOCUS_ALL, "menu host button supports keyboard focus")
	_check(menu.get_node("%JoinButton").focus_mode == Control.FOCUS_ALL, "menu join button supports keyboard focus")
	_check(menu.get_node("%JoinButton").mouse_filter == Control.MOUSE_FILTER_STOP, "menu actions receive mouse input")
	await _capture("menu", resolution, evidence_dir)

	if resolution_index == 0:
		_mouse_click(menu.get_node("%HostButton"))
	else:
		menu.get_node("%HostButton").grab_focus()
		_press_key(KEY_ENTER)
	await process_frame
	var host_panel: Control = _last_control_child(menu)
	_check(host_panel != null and host_panel.has_node("%PortInput"), "menu opens host panel")
	if host_panel == null:
		menu.queue_free()
		return
	_check(host_panel.get_node("%PortInput").text == "2456", "host panel shows default port")
	_check(host_panel.get_node("%CreateButton").focus_mode == Control.FOCUS_ALL, "host create action supports keyboard focus")
	await _capture("host-panel", resolution, evidence_dir)
	host_panel.get_node("%PortInput").text = "0"
	host_panel.get_node("%CreateButton").pressed.emit()
	_check(str(host_panel.get_node("%StatusLabel").text).contains("1 y 65535"), "host panel shows invalid port inline")
	host_panel.get_node("%CancelButton").pressed.emit()
	await process_frame
	menu.get_node("%JoinButton").grab_focus()
	_press_key(KEY_ENTER)
	await process_frame
	var join_panel: Control = _last_control_child(menu)
	_check(join_panel != null and join_panel.has_node("%AddressInput"), "menu opens join panel")
	if join_panel == null:
		menu.queue_free()
		return
	_check(join_panel.get_node("%AddressInput").focus_mode == Control.FOCUS_ALL, "join address supports keyboard focus")
	await _capture("join-panel", resolution, evidence_dir)
	join_panel.get_node("%AddressInput").text = "not-an-ip"
	join_panel.get_node("%JoinButton").pressed.emit()
	_check(str(join_panel.get_node("%StatusLabel").text).contains("IPv4"), "join panel rejects invalid IP inline")
	join_panel.get_node("%AddressInput").text = "127.0.0.1"
	join_panel.get_node("%PortInput").text = str(24560 + resolution_index)
	join_panel.get_node("%JoinButton").pressed.emit()
	await process_frame
	await process_frame
	var lobby: Control = menu.get_node_or_null("Lobby")
	_check(lobby != null, "valid join intent navigates into the lobby")
	if lobby == null:
		menu.queue_free()
		return
	_check(lobby.get_node("NetworkManager").multiplayer.multiplayer_peer != null, "join flow starts the LAN client")
	var join_status := str(lobby.get("_status_label").text).to_lower()
	var roster_status := str(lobby.get("_roster_count_label").text).to_lower()
	_check(roster_status.contains("conectando") or join_status.contains("conectando") or join_status.contains("no se pudo conectar"), "connection progress or refusal state is visible")
	await _capture("lobby-connection-state", resolution, evidence_dir)
	lobby.process_mode = Node.PROCESS_MODE_DISABLED
	lobby.get_node("NetworkManager").close_session()
	lobby.call("_on_lobby_rejected", "Host sin respuesta (preview visual)")
	_check(str(lobby.get("_status_label").text).contains("Host sin respuesta"), "rejection reason is visible")
	await _capture("lobby-rejected-preview", resolution, evidence_dir)
	lobby.call("_on_leave_pressed")
	await process_frame
	await process_frame
	_check(menu.get_node("%MenuPanel").visible, "return action restores main menu after failed connection")

	menu.get_node("%HostButton").pressed.emit()
	await process_frame
	host_panel = _last_control_child(menu)
	host_panel.get_node("%PortInput").text = str(25050 + resolution_index)
	host_panel.get_node("%CreateButton").pressed.emit()
	await process_frame
	await process_frame
	lobby = menu.get_node_or_null("Lobby")
	_check(lobby != null, "valid host intent navigates into the lobby")
	if lobby != null:
		var manager: Node = lobby.get_node("NetworkManager")
		_check(manager.multiplayer.is_server() and manager.players.size() == 1, "host flow starts authoritative LAN server")
		_check(lobby.get("_start_button").disabled, "host start stays disabled with fewer than six players")
		_check(str(lobby.get("_start_hint_label").text).contains("Esperando jugadores"), "host sees why start is unavailable")
		_check(lobby.get("_start_button").focus_mode == Control.FOCUS_ALL, "lobby actions support keyboard focus")
		await _capture("lobby-host-partial", resolution, evidence_dir)
		lobby.get("_leave_button").pressed.emit()
		await process_frame
	menu.queue_free()
	await process_frame
	await process_frame


func _last_control_child(parent: Node) -> Control:
	if parent.get_child_count() == 0:
		return null
	return parent.get_child(parent.get_child_count() - 1) as Control


func _capture(screen_name: String, resolution: Vector2i, evidence_dir: String) -> void:
	await create_timer(0.15).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_check(false, "capture %s at %s produced an image" % [screen_name, resolution])
		return
	var filename := "%s_%dx%d.png" % [screen_name, resolution.x, resolution.y]
	var output_path := evidence_dir.path_join(filename)
	var save_error := image.save_png(output_path)
	_check(save_error == OK, "capture saved: %s" % output_path)


func _press_key(keycode: Key) -> void:
	var key_down := InputEventKey.new()
	key_down.keycode = keycode
	key_down.pressed = true
	root.push_input(key_down)
	var key_up := InputEventKey.new()
	key_up.keycode = keycode
	key_up.pressed = false
	root.push_input(key_up)


func _mouse_click(button: Button) -> void:
	var position := button.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = position
	press.global_position = position
	press.pressed = true
	root.push_input(press)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = position
	release.global_position = position
	release.pressed = false
	root.push_input(release)


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
	else:
		_failures += 1
		printerr("FAIL: %s" % description)
