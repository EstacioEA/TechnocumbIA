extends SceneTree

const NetworkManagerScript = preload("res://scripts/network/network_manager.gd")
const TEST_ADDRESS := "127.0.0.1"
const TIMEOUT_SECONDS := 12.0

var _manager: Node
var _role := ""
var _validation_error_visible := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		_fail("Uso: lan_transport_test.gd -- <host|client> <port>")
		return
	_role = str(args[0])
	var port_text := str(args[1])
	if not port_text.is_valid_int():
		_fail("El puerto de prueba debe ser entero.")
		return
	var port := port_text.to_int()
	if _role not in ["host", "client"]:
		_fail("Rol de prueba desconocido: %s" % _role)
		return

	_manager = NetworkManagerScript.new()
	root.add_child(_manager)
	await process_frame
	if not _test_validation():
		return

	if _role == "host":
		_manager.peer_joined.connect(_on_host_peer_joined)
		if _manager.host_game(port) != OK:
			_fail("El host ENet no pudo iniciar en el puerto %d." % port)
			return
		print("HOST_READY port=%d" % port)
	else:
		_manager.status_changed.connect(_on_client_status_changed)
		_manager.lobby_updated.connect(_on_client_lobby_updated)
		_manager.lobby_rejected.connect(_on_client_rejected)
		if _manager.join_game(TEST_ADDRESS, port) != OK:
			_fail("El cliente no pudo iniciar la conexión a %s:%d." % [TEST_ADDRESS, port])
			return
		print("CLIENT_CONNECTING address=%s port=%d" % [TEST_ADDRESS, port])

	var timer := create_timer(TIMEOUT_SECONDS)
	timer.timeout.connect(func() -> void: _fail("Timeout esperando el evento de conexión del %s." % _role))


func _test_validation() -> bool:
	_manager.status_changed.connect(_on_validation_status_changed)
	if not _manager.validate_ip(TEST_ADDRESS):
		_fail("Se rechazó una dirección IPv4 válida.")
		return false
	if _manager.validate_ip("no-es-una-ip"):
		_fail("Se aceptó una dirección IP inválida.")
		return false
	if not _manager.validate_port(1) or not _manager.validate_port(65535):
		_fail("Se rechazó un límite válido de puerto.")
		return false
	if _manager.validate_port(0) or _manager.validate_port(65536):
		_fail("Se aceptó un puerto fuera de rango.")
		return false
	if _manager.join_game("no-es-una-ip", 24567) == OK or not _validation_error_visible:
		_fail("El error por IP inválida no se reportó en status_changed.")
		return false
	print("VALIDATION_PASS")
	return true


func _on_validation_status_changed(message: String) -> void:
	_validation_error_visible = message.contains("IP")


func _on_host_peer_joined(peer_id: int, _display_name: String, _ready: bool) -> void:
	if peer_id <= 1:
		_fail("El servidor notificó un peer remoto inválido.")
		return
	print("HOST_PEER_JOINED peer_id=%d" % peer_id)
	_finish_host_after_roster_broadcast()


func _finish_host_after_roster_broadcast() -> void:
	await create_timer(1.0).timeout
	quit(0)


func _on_client_status_changed(message: String) -> void:
	if message == "Conectado al host.":
		print("CLIENT_CONNECTED_WAITING_FOR_ROSTER")


func _on_client_lobby_updated(snapshot: Array[Dictionary]) -> void:
	if _manager.multiplayer.multiplayer_peer == null:
		return
	var local_id: int = _manager.multiplayer.get_unique_id()
	for entry: Dictionary in snapshot:
		if entry.get("id") == local_id:
			print("CLIENT_CONNECTED roster_size=%d" % snapshot.size())
			quit(0)


func _on_client_rejected(reason: String) -> void:
	_fail("Conexión rechazada: %s" % reason)


func _fail(message: String) -> void:
	printerr("LAN_TRANSPORT_TEST_FAIL role=%s: %s" % [_role, message])
	quit(1)
