extends Control

const HOST_PANEL_SCENE := preload("res://scenes/menu/host_panel.tscn")

signal host_requested
signal join_requested

@onready var menu_panel: PanelContainer = %MenuPanel
@onready var host_button: Button = %HostButton
@onready var join_button: Button = %JoinButton
@onready var exit_button: Button = %ExitButton
@onready var status_label: Label = %StatusLabel

var _host_panel: Control


func _ready() -> void:
	_apply_panel_style()
	_apply_button_style(host_button, true)
	_apply_button_style(join_button, false)
	_apply_button_style(exit_button, false)
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	host_button.grab_focus.call_deferred()


func _apply_panel_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#1d2a35")
	panel_style.border_color = Color("#354957")
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(18)
	menu_panel.add_theme_stylebox_override("panel", panel_style)


func _apply_button_style(button: Button, is_primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#f2c14e") if is_primary else Color("#263946")
	normal.border_color = Color("#f7d779") if is_primary else Color("#496171")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 20.0
	normal.content_margin_right = 20.0
	normal.content_margin_top = 14.0
	normal.content_margin_bottom = 14.0

	var hovered := normal.duplicate() as StyleBoxFlat
	hovered.bg_color = Color("#f7d779") if is_primary else Color("#344d5d")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#dca936") if is_primary else Color("#1d2a35")
	var focused := StyleBoxFlat.new()
	focused.bg_color = Color("#f2c14e", 0.16)
	focused.border_color = Color("#f2c14e")
	focused.set_border_width_all(2)
	focused.set_corner_radius_all(10)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hovered)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focused)
	button.add_theme_color_override("font_color", Color("#101923") if is_primary else Color("#f4f1de"))
	button.add_theme_color_override("font_hover_color", Color("#101923") if is_primary else Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#101923") if is_primary else Color("#f4f1de"))
	button.add_theme_font_size_override("font_size", 20)
	button.focus_mode = Control.FOCUS_ALL


func _on_host_pressed() -> void:
	host_requested.emit()
	menu_panel.visible = false
	_host_panel = HOST_PANEL_SCENE.instantiate()
	_host_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_host_panel.connect("cancel_requested", _on_host_cancelled)
	_host_panel.connect("create_requested", _on_host_create_requested)
	add_child(_host_panel)


func _on_host_cancelled() -> void:
	_host_panel.queue_free()
	_host_panel = null
	menu_panel.visible = true
	host_button.grab_focus()


func _on_host_create_requested(port: int) -> void:
	status_label.text = "Puerto %d validado; el transporte se conectará en otra tarea." % port


func _on_join_pressed() -> void:
	status_label.text = "La conexión por IP se conectará en la siguiente tarea."
	join_requested.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()
