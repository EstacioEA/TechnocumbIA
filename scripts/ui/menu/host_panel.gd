extends Control

signal create_requested(port: int)
signal cancel_requested

const DEFAULT_PORT := 2456

@onready var port_input: LineEdit = %PortInput
@onready var status_label: Label = %StatusLabel
@onready var create_button: Button = %CreateButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	port_input.text = str(DEFAULT_PORT)
	create_button.pressed.connect(_on_create_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	port_input.text_submitted.connect(_on_port_submitted)
	_apply_button_style(create_button, true)
	_apply_button_style(cancel_button, false)
	port_input.grab_focus.call_deferred()
	port_input.select_all.call_deferred()


func _on_port_submitted(_submitted_text: String) -> void:
	_on_create_pressed()


func _on_create_pressed() -> void:
	var port_text := port_input.text.strip_edges()
	if not port_text.is_valid_int():
		_show_error("Escribe un puerto numérico entre 1 y 65535.")
		return

	var port := port_text.to_int()
	if port < 1 or port > 65535:
		_show_error("El puerto debe estar entre 1 y 65535.")
		return

	status_label.text = "Puerto válido. El servidor se conectará en el siguiente paso."
	status_label.add_theme_color_override("font_color", Color("#68d391"))
	create_requested.emit(port)


func _on_cancel_pressed() -> void:
	cancel_requested.emit()


func _show_error(message: String) -> void:
	status_label.text = message
	status_label.add_theme_color_override("font_color", Color("#f06c62"))
	port_input.grab_focus()
	port_input.select_all()


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
