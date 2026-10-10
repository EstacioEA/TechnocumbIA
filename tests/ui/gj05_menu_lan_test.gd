extends SceneTree

const MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")

var _role := ""
var _port := 0
var _marker_dir := ""
var _network: Node
var _menu: Control
var _done := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		_fail("Usage: gj05_menu_lan_test.gd -- <host|client> <port> <marker_dir>")
		return
	_role = str(args[0])
	if not str(args[1]).is_valid_int() or _role not in ["host", "client"]:
		_fail("Invalid role or port.")
		return
	_port = str(args[1]).to_int()
	_marker_dir = str(args[2])
	var mkdir_error := DirAccess.make_dir_recursive_absolute(_marker_dir)
	if mkdir_error != OK and mkdir_error != ERR_ALREADY_EXISTS:
		_fail("Could not create marker directory.")
		return

	_menu = MENU_SCENE.instantiate()
	root.add_child(_menu)
	await process_frame
	await process_frame
	if _role == "host":
		_menu.get_node("%HostButton").pressed.emit()
		await process_frame
		var host_panel: Control = _menu.get_child(_menu.get_child_count() - 1)
		host_panel.get_node("%PortInput").text = str(_port)
		_signal_lobby_before_request(host_panel, "%CreateButton")
	else:
		_menu.get_node("%JoinButton").pressed.emit()
		await process_frame
		var join_panel: Control = _menu.get_child(_menu.get_child_count() - 1)
		join_panel.get_node("%AddressInput").text = "127.0.0.1"
		join_panel.get_node("%PortInput").text = str(_port)
		_signal_lobby_before_request(join_panel, "%JoinButton")

	var timeout := create_timer(15.0)
	timeout.timeout.connect(func() -> void:
		if not _done:
			_fail("Timed out waiting for the two-player lobby through the menu flow."))


func _signal_lobby_before_request(panel: Control, button_path: NodePath) -> void:
	var request_button: Button = panel.get_node(button_path)
	if button_path == NodePath("%CreateButton"):
		request_button.pressed.emit()
	else:
		request_button.pressed.emit()
	var lobby: Control = _menu.get_node_or_null("Lobby")
	if lobby == null:
		_fail("The menu did not navigate into the lobby.")
		return
	_network = lobby.get_node("NetworkManager")
	_network.lobby_updated.connect(_on_lobby_updated)


func _on_lobby_updated(snapshot: Array[Dictionary]) -> void:
	if _done or snapshot.size() != 2:
		return
	if _role == "client":
		var local_id: int = _network.multiplayer.get_unique_id()
		var has_local_player := false
		for entry: Dictionary in snapshot:
			if entry.get("id") == local_id:
				has_local_player = true
		if not has_local_player:
			return
	_done = true
	_write_marker("%s-menu-lobby-connected" % _role)
	print("GJ05_MENU_LAN_PASS role=%s roster=%d" % [_role, snapshot.size()])
	if _role == "host":
		await create_timer(0.6).timeout
		_network.close_session()
	quit(0)


func _write_marker(marker_name: String) -> void:
	var marker := FileAccess.open(_marker_dir.path_join("%s.ok" % marker_name), FileAccess.WRITE)
	if marker == null:
		_fail("Could not write marker %s." % marker_name)
		return
	marker.store_string("PASS\n")
	marker.close()


func _fail(message: String) -> void:
	printerr("GJ05_MENU_LAN_FAIL role=%s: %s" % [_role, message])
	quit(1)
