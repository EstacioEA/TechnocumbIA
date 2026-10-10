extends Control

signal join_requested(address: String, port: int)
signal cancel_requested

const DEFAULT_ADDRESS := "127.0.0.1"
const DEFAULT_PORT := 2456

@onready var address_input: LineEdit = %AddressInput
@onready var port_input: LineEdit = %PortInput
@onready var status_label: Label = %StatusLabel
@onready var join_button: Button = %JoinButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	address_input.text = DEFAULT_ADDRESS
	port_input.text = str(DEFAULT_PORT)
	join_button.pressed.connect(_on_join_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	address_input.text_submitted.connect(_on_address_submitted)
	port_input.text_submitted.connect(_on_port_submitted)
	_apply_button_style(join_button, true)
	_apply_button_style(cancel_button, false)
	address_input.grab_focus.call_deferred()
	address_input.select_all.call_deferred()


func _on_address_submitted(_submitted_text: String) -> void:
	_on_join_pressed()


func _on_port_submitted(_submitted_text: String) -> void:
	_on_join_pressed()


func _on_join_pressed() -> void:
	var address := address_input.text.strip_edges()
	if not address.is_valid_ip_address():
		_show_error("Escribe una dirección IPv4 o IPv6 válida.", address_input)
		return

	var port_text := port_input.text.strip_edges()
	if not port_text.is_valid_int():
		_show_error("Escribe un puerto numérico entre 1 y 65535.", port_input)
		return

	var port := port_text.to_int()
	if port < 1 or port > 65535:
		_show_error("El puerto debe estar entre 1 y 65535.", port_input)
		return

	status_label.text = "Dirección válida. La conexión se integrará en la siguiente tarea."
	status_label.add_theme_color_override("font_color", Color("#68d391"))
	join_requested.emit(address, port)


func _on_cancel_pressed() -> void:
	cancel_requested.emit()


func _show_error(message: String, target: LineEdit) -> void:
	status_label.text = message
	status_label.add_theme_color_override("font_color", Color("#f06c62"))
	target.grab_focus()
	target.select_all()


func _apply_button_style(button: Button, is_primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#f2c14e") if is_primary else Color("#263946")
	normal.border_color = Color("#f7d779") if is_primary else Color("#496171")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 18.0
	normal.content_margin_right = 18.0
	normal.content_margin_top = 12.0
	normal.content_margin_bottom = 12.0

	var hovered := normal.duplicate() as StyleBoxFlat
	hovered.bg_color = Color("#f7d779") if is_primary else Color("#344d5d")
	var focused := StyleBoxFlat.new()
	focused.bg_color = Color("#f2c14e", 0.16)
	focused.border_color = Color("#f2c14e")
	focused.set_border_width_all(2)
	focused.set_corner_radius_all(10)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hovered)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_color_override("font_color", Color("#101923") if is_primary else Color("#f4f1de"))
	button.add_theme_color_override("font_hover_color", Color("#101923") if is_primary else Color("#ffffff"))
	button.add_theme_font_size_override("font_size", 18)
	button.focus_mode = Control.FOCUS_ALL
