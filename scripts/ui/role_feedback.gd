class_name RoleFeedback
extends Control

const IMPACT_ICON := "res://assets/ui/feedback/impact.svg"
const ACTION_ICON := "res://assets/ui/feedback/action.svg"
const DISCONNECT_ICON := "res://assets/ui/feedback/disconnect.svg"

const IMPACT := "IMPACT"
const ACTION := "ACTION"
const DISCONNECT := "DISCONNECT"
const REAL := "REAL"
const SIMULATED := "SIMULATED"

var _event_icon: TextureRect
var _event_label: Label
var _source_label: Label
var _detail_label: Label
var _event_type := ""
var _source_kind := ""

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	var panel := PanelContainer.new()
	panel.name = "EventPanel"
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.position = Vector2(-360.0, 24.0)
	panel.size = Vector2(336.0, 112.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var layout := HBoxContainer.new()
	layout.name = "EventLayout"
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)
	_event_icon = TextureRect.new()
	_event_icon.name = "EventIcon"
	_event_icon.custom_minimum_size = Vector2(32.0, 32.0)
	_event_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_event_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_event_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	layout.add_child(_event_icon)
	var text_layout := VBoxContainer.new()
	text_layout.name = "EventText"
	text_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(text_layout)
	_event_label = Label.new()
	_event_label.name = "Event"
	_event_label.text = "SIN EVENTO"
	text_layout.add_child(_event_label)
	_source_label = Label.new()
	_source_label.name = "Source"
	_source_label.text = "FUENTE: ESPERANDO"
	_source_label.add_theme_font_size_override("font_size", 11)
	text_layout.add_child(_source_label)
	_detail_label = Label.new()
	_detail_label.name = "Detail"
	_detail_label.text = "Solo se muestran señales recibidas."
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_font_size_override("font_size", 12)
	text_layout.add_child(_detail_label)

func present_event(event_type: String, received_detail: String, source_kind: String = REAL) -> void:
	var normalized_type := event_type.to_upper()
	var normalized_source := source_kind.to_upper()
	if normalized_type not in [IMPACT, ACTION, DISCONNECT]:
		push_error("Tipo de feedback no soportado: %s" % event_type)
		return
	if normalized_source != REAL and normalized_source != SIMULATED:
		push_error("Fuente de feedback no soportada: %s" % source_kind)
		return
	_event_type = normalized_type
	_source_kind = normalized_source
	_event_icon.texture = load(_icon_path(_event_type))
	_event_label.text = _event_text(_event_type)
	_source_label.text = "FUENTE: %s" % ("REAL · SEÑAL RECIBIDA" if _source_kind == REAL else "SIMULADA · PREVIEW")
	_detail_label.text = received_detail

func get_event_type() -> String:
	return _event_type

func get_source_kind() -> String:
	return _source_kind

func _icon_path(event_type: String) -> String:
	match event_type:
		IMPACT:
			return IMPACT_ICON
		ACTION:
			return ACTION_ICON
		DISCONNECT:
			return DISCONNECT_ICON
		_:
			return ACTION_ICON

func _event_text(event_type: String) -> String:
	match event_type:
		IMPACT:
			return "IMPACTO RECIBIDO"
		ACTION:
			return "ACCIÓN RECIBIDA"
		DISCONNECT:
			return "DESCONEXIÓN RECIBIDA"
		_:
			return "EVENTO RECIBIDO"
