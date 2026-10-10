extends Control

@onready var network: Node = $NetworkManager

var _players_label: Label
var _status_label: Label
var _host_button: Button
var _join_button: Button
var _ready_button: Button
var _start_button: Button
var _ip_input: LineEdit
var _port_input: LineEdit


func _ready() -> void:
	_build_ui()
	network.lobby_updated.connect(_on_lobby_updated)
	network.status_changed.connect(_on_status_changed)
	network.lobby_rejected.connect(_on_lobby_rejected)
	network.lobby_start.connect(_on_lobby_start)
	_on_lobby_updated(network.get_lobby_snapshot())


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("171923")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	move_child(background, 0)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 500)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var title := Label.new()
	title.text = "Papoi · Lobby LAN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)

	var host_row := HBoxContainer.new()
	column.add_child(host_row)
	_host_button = Button.new()
	_host_button.text = "Crear partida"
	_host_button.pressed.connect(_on_host_pressed)
	host_row.add_child(_host_button)
	_port_input = LineEdit.new()
	_port_input.placeholder_text = "Puerto (2456)"
	_port_input.text = "2456"
	_port_input.max_length = 5
	_port_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host_row.add_child(_port_input)

	var join_row := HBoxContainer.new()
	column.add_child(join_row)
	_ip_input = LineEdit.new()
	_ip_input.placeholder_text = "IP del host, por ejemplo 192.168.1.20"
	_ip_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	join_row.add_child(_ip_input)
	_join_button = Button.new()
	_join_button.text = "Unirse"
	_join_button.pressed.connect(_on_join_pressed)
	join_row.add_child(_join_button)

	var lobby_heading := Label.new()
	lobby_heading.text = "Jugadores (máximo 6)"
	lobby_heading.add_theme_font_size_override("font_size", 20)
	column.add_child(lobby_heading)
	_players_label = Label.new()
	_players_label.custom_minimum_size = Vector2(0, 180)
	_players_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_players_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_players_label)

	var actions := HBoxContainer.new()
	column.add_child(actions)
	_ready_button = Button.new()
	_ready_button.text = "Cambiar listo"
	_ready_button.pressed.connect(_on_ready_pressed)
	_ready_button.disabled = true
	actions.add_child(_ready_button)
	_start_button = Button.new()
	_start_button.text = "Iniciar partida"
	_start_button.pressed.connect(_on_start_pressed)
	_start_button.visible = false
	_start_button.disabled = true
	actions.add_child(_start_button)

	_status_label = Label.new()
	_status_label.text = "Crea una partida o únete por IP."
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status_label)


func _on_host_pressed() -> void:
	var port := _read_port()
	if port < 0:
		return
	if network.host_game(port) == OK:
		_update_controls()


func _on_join_pressed() -> void:
	var port := _read_port()
	if port < 0:
		return
	if network.join_game(_ip_input.text, port) == OK:
		_update_controls()


func _read_port() -> int:
	var value := _port_input.text.strip_edges()
	if not value.is_valid_int():
		_on_status_changed("El puerto debe ser un número entre 1 y 65535.")
		return -1
	var port := value.to_int()
	if not network.validate_port(port):
		_on_status_changed("El puerto debe estar entre 1 y 65535.")
		return -1
	return port


func _on_ready_pressed() -> void:
	var local_id := network.multiplayer.get_unique_id()
	var current_ready: bool = network.players.get(local_id, {}).get("ready", false)
	if network.set_local_ready(not current_ready):
		_update_controls()


func _on_start_pressed() -> void:
	network.request_start_match()


func _on_lobby_updated(snapshot: Array[Dictionary]) -> void:
	var lines := PackedStringArray()
	for entry: Dictionary in snapshot:
		var role := "Host" if entry["id"] == 1 else "Cliente"
		var ready_text := "LISTO" if entry["ready"] else "Esperando"
		lines.append("%s — %s — %s" % [role, entry["name"], ready_text])
	if lines.is_empty():
		lines.append("Aún no hay jugadores conectados.")
	_players_label.text = "\n".join(lines)
	_update_controls()


func _on_status_changed(message: String) -> void:
	_status_label.text = message


func _on_lobby_rejected(reason: String) -> void:
	_status_label.text = "Conexión rechazada: " + reason


func _on_lobby_start() -> void:
	_status_label.text = "Lobby iniciado. Conecta aquí la transición a la escena de partida."


func _update_controls() -> void:
	var peer: MultiplayerPeer = network.multiplayer.multiplayer_peer
	var connected := peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
	_ready_button.disabled = not connected
	var is_host := connected and network.multiplayer.is_server()
	_start_button.visible = is_host
	var all_ready := network.players.size() == 6
	for player_data: Dictionary in network.players.values():
		all_ready = all_ready and player_data.get("ready", false)
	_start_button.disabled = not is_host or not all_ready
	_host_button.disabled = connected
	_join_button.disabled = connected
