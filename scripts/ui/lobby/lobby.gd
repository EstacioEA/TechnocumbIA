extends Control

const GAME_SCENE := preload("res://scenes/game/papoi_game.tscn")

signal menu_requested

@onready var network: Node = $NetworkManager

var _players_label: Label
var _status_label: Label
var _roster_count_label: Label
var _start_hint_label: Label
var _host_button: Button
var _join_button: Button
var _ready_button: Button
var _start_button: Button
var _leave_button: Button
var _ip_input: LineEdit
var _port_input: LineEdit
var _slot_labels: Array[Label] = []


func _ready() -> void:
	_build_ui()
	network.lobby_updated.connect(_on_lobby_updated)
	network.status_changed.connect(_on_status_changed)
	network.lobby_rejected.connect(_on_lobby_rejected)
	network.lobby_start.connect(_on_lobby_start)
	_on_lobby_updated(network.get_lobby_snapshot())


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#101923")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)
	var glow := ColorRect.new()
	glow.color = Color("#f2c14e")
	glow.anchor_right = 1.0
	glow.anchor_bottom = 0.012
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1000, 640)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var eyebrow := Label.new()
	eyebrow.text = "PAPOI  /  PARTIDA LAN 3v3"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", Color("#68d391"))
	eyebrow.add_theme_font_size_override("font_size", 14)
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = "Sala de espera"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color("#f4f1de"))
	title.add_theme_font_size_override("font_size", 34)
	column.add_child(title)

	var connection_row := HBoxContainer.new()
	connection_row.add_theme_constant_override("separation", 10)
	column.add_child(connection_row)
	_host_button = Button.new()
	_host_button.text = "CREAR PARTIDA"
	_host_button.pressed.connect(_on_host_pressed)
	connection_row.add_child(_host_button)
	_port_input = LineEdit.new()
	_port_input.placeholder_text = "Puerto (2456)"
	_port_input.text = "2456"
	_port_input.max_length = 5
	_port_input.custom_minimum_size.x = 120
	_port_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connection_row.add_child(_port_input)
	_ip_input = LineEdit.new()
	_ip_input.placeholder_text = "IP del host (ej. 192.168.1.20)"
	_ip_input.max_length = 45
	_ip_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connection_row.add_child(_ip_input)
	_join_button = Button.new()
	_join_button.text = "UNIRSE"
	_join_button.pressed.connect(_on_join_pressed)
	connection_row.add_child(_join_button)

	var roster_header := HBoxContainer.new()
	column.add_child(roster_header)
	var lobby_heading := Label.new()
	lobby_heading.text = "JUGADORES"
	lobby_heading.add_theme_color_override("font_color", Color("#f4f1de"))
	lobby_heading.add_theme_font_size_override("font_size", 18)
	lobby_heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_header.add_child(lobby_heading)
	_roster_count_label = Label.new()
	_roster_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_roster_count_label.add_theme_color_override("font_color", Color("#b6c5cb"))
	roster_header.add_child(_roster_count_label)

	var slots_grid := GridContainer.new()
	slots_grid.columns = 2
	slots_grid.add_theme_constant_override("h_separation", 12)
	slots_grid.add_theme_constant_override("v_separation", 8)
	column.add_child(slots_grid)
	for slot_index in range(6):
		var slot_card := PanelContainer.new()
		slot_card.custom_minimum_size = Vector2(0, 74)
		slot_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_card.add_theme_stylebox_override("panel", _make_slot_style(false, false))
		slots_grid.add_child(slot_card)
		var slot_margin := MarginContainer.new()
		slot_margin.add_theme_constant_override("margin_left", 14)
		slot_margin.add_theme_constant_override("margin_top", 8)
		slot_margin.add_theme_constant_override("margin_right", 14)
		slot_margin.add_theme_constant_override("margin_bottom", 8)
		slot_card.add_child(slot_margin)
		var slot_label := Label.new()
		slot_label.text = "PUESTO %d  ·  VACANTE\nEsperando jugador" % (slot_index + 1)
		slot_label.add_theme_color_override("font_color", Color("#83949c"))
		slot_label.add_theme_font_size_override("font_size", 15)
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_margin.add_child(slot_label)
		_slot_labels.append(slot_label)

	# Keep a text projection for the existing network integration checks.
	_players_label = Label.new()
	_players_label.visible = false
	column.add_child(_players_label)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	_ready_button = Button.new()
	_ready_button.text = "CAMBIAR LISTO"
	_ready_button.pressed.connect(_on_ready_pressed)
	_ready_button.disabled = true
	_ready_button.custom_minimum_size.y = 48
	_apply_button_style(_ready_button, false)
	actions.add_child(_ready_button)
	_start_button = Button.new()
	_start_button.text = "INICIAR PARTIDA"
	_start_button.disabled = true
	_start_button.custom_minimum_size.y = 48
	_apply_button_style(_start_button, true)
	_start_button.pressed.connect(_on_start_pressed)
	actions.add_child(_start_button)
	_leave_button = Button.new()
	_leave_button.text = "VOLVER AL MENÚ"
	_leave_button.custom_minimum_size.y = 48
	_apply_button_style(_leave_button, false)
	_leave_button.pressed.connect(_on_leave_pressed)
	actions.add_child(_leave_button)

	_start_hint_label = Label.new()
	_start_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_start_hint_label.add_theme_color_override("font_color", Color("#b6c5cb"))
	_start_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_start_hint_label)
	_status_label = Label.new()
	_status_label.text = "Crea una partida o únete por IP."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color("#b6c5cb"))
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status_label)
	_apply_button_style(_host_button, true)
	_apply_button_style(_join_button, false)
	_update_controls()


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1d2a35")
	style.border_color = Color("#354957")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	return style


func _make_slot_style(is_occupied: bool, is_ready: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#263946") if is_occupied else Color("#17232d")
	style.border_color = Color("#68d391") if is_ready else Color("#496171")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	return style


func _apply_button_style(button: Button, is_primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#f2c14e") if is_primary else Color("#263946")
	normal.border_color = Color("#f7d779") if is_primary else Color("#496171")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(9)
	var hovered := normal.duplicate() as StyleBoxFlat
	hovered.bg_color = Color("#f7d779") if is_primary else Color("#344d5d")
	var focused := StyleBoxFlat.new()
	focused.bg_color = Color("#f2c14e", 0.16)
	focused.border_color = Color("#f2c14e")
	focused.set_border_width_all(2)
	focused.set_corner_radius_all(9)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hovered)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_color_override("font_color", Color("#101923") if is_primary else Color("#f4f1de"))
	button.add_theme_font_size_override("font_size", 14)
	button.focus_mode = Control.FOCUS_ALL


func _on_host_pressed() -> void:
	var port := _read_port()
	if port < 0:
		return
	start_host(port)


func _on_join_pressed() -> void:
	var port := _read_port()
	if port < 0:
		return
	join_host(_ip_input.text, port)


func start_host(port: int) -> void:
	if network.host_game(port) == OK:
		_update_controls()


func join_host(address: String, port: int) -> void:
	if network.join_game(address, port) == OK:
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


func _on_leave_pressed() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	network.close_session()
	menu_requested.emit()


func _on_lobby_updated(snapshot: Array[Dictionary]) -> void:
	var lines := PackedStringArray()
	var connected_count := mini(snapshot.size(), _slot_labels.size())
	for slot_index in range(_slot_labels.size()):
		var slot_label := _slot_labels[slot_index]
		var slot_card := slot_label.get_parent().get_parent() as PanelContainer
		if slot_index >= connected_count:
			slot_label.text = "PUESTO %d  ·  VACANTE\nEsperando jugador" % (slot_index + 1)
			slot_label.add_theme_color_override("font_color", Color("#83949c"))
			slot_card.add_theme_stylebox_override("panel", _make_slot_style(false, false))
			continue
		var entry: Dictionary = snapshot[slot_index]
		var is_host: bool = entry["id"] == 1
		var is_ready: bool = bool(entry["ready"])
		var role := "HOST · ID %d" % entry["id"] if is_host else "CLIENTE · ID %d" % entry["id"]
		var ready_text := "● LISTO" if is_ready else "◷ ESPERANDO"
		slot_label.text = "%s\n%s   %s" % [role, entry["name"], ready_text]
		slot_label.add_theme_color_override("font_color", Color("#f4f1de"))
		slot_card.add_theme_stylebox_override("panel", _make_slot_style(true, is_ready))
		lines.append("%s — %s — %s" % ["Host" if is_host else "Cliente", entry["name"], "LISTO" if is_ready else "Esperando"])
	if lines.is_empty():
		lines.append("Aún no hay jugadores conectados.")
	_players_label.text = "\n".join(lines)
	var peer: MultiplayerPeer = network.multiplayer.multiplayer_peer
	if peer is ENetMultiplayerPeer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		_roster_count_label.text = "CONECTANDO AL HOST…"
	elif peer is ENetMultiplayerPeer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and snapshot.is_empty():
		_roster_count_label.text = "CONECTADO · SINCRONIZANDO SALA…"
	elif snapshot.is_empty():
		_roster_count_label.text = "SIN CONEXIÓN · 0 / 6"
	else:
		_roster_count_label.text = "SALA LLENA · 6 / 6" if connected_count == 6 else "SALA PARCIAL · %d / 6" % connected_count
	_update_controls()


func _on_status_changed(message: String) -> void:
	_status_label.text = message
	var lowered := message.to_lower()
	var is_problem := lowered.contains("desconect") or lowered.contains("rechaz") or lowered.contains("no se pudo")
	_status_label.add_theme_color_override("font_color", Color("#f06c62") if is_problem else Color("#b6c5cb"))


func _on_lobby_rejected(reason: String) -> void:
	_status_label.text = "Conexión rechazada: " + reason
	_status_label.add_theme_color_override("font_color", Color("#f06c62"))


func _on_lobby_start() -> void:
	if get_tree().root.has_node("PapoiGameSession"):
		return
	var game_session: Node = GAME_SCENE.instantiate()
	game_session.name = "PapoiGameSession"
	game_session.configure_network_manager(network)
	get_tree().root.add_child(game_session)
	visible = false


func _update_controls() -> void:
	var connected := _has_active_lobby()
	var peer: MultiplayerPeer = network.multiplayer.multiplayer_peer
	var connecting := peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING
	_ready_button.disabled = not connected
	var is_host := connected and network.multiplayer.is_server()
	var all_ready: bool = network.players.size() == 6
	for player_data: Dictionary in network.players.values():
		all_ready = all_ready and bool(player_data.get("ready", false))
	_start_button.disabled = not is_host or not all_ready
	_host_button.disabled = connected or connecting
	_join_button.disabled = connected or connecting
	_leave_button.disabled = not peer is ENetMultiplayerPeer
	if not connected:
		_start_hint_label.text = "Conectando…" if connecting else "Conéctate a una sala para cambiar tu estado o iniciar."
	elif not is_host:
		_start_hint_label.text = "Solo el host puede iniciar la partida."
	elif network.players.size() < 6:
		_start_hint_label.text = "Esperando jugadores: %d / 6." % network.players.size()
	elif not all_ready:
		_start_hint_label.text = "Esperando que los seis jugadores estén listos."
	else:
		_start_hint_label.text = "Los seis están listos. El host puede iniciar."


func _has_active_lobby() -> bool:
	var peer: MultiplayerPeer = network.multiplayer.multiplayer_peer
	return peer is ENetMultiplayerPeer and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and not network.players.is_empty()
