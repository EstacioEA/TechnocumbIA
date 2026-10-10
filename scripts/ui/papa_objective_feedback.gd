class_name PapaObjectiveFeedback
extends Control

const CAPTURED_ICON := "res://assets/ui/feedback/papa_captured.svg"
const TRANSPORTING_ICON := "res://assets/ui/feedback/papa_transporting.svg"
const COOKING_ICON := "res://assets/ui/feedback/papa_cooking.svg"
const RESCUED_ICON := "res://assets/ui/feedback/papa_rescued.svg"
const ESCAPED_ICON := "res://assets/ui/feedback/papa_escaped.svg"

const CAPTURED := "CAPTURED"
const TRANSPORTING := "TRANSPORTING"
const COOKING := "COOKING"
const RESCUED := "RESCUED"
const ESCAPED := "ESCAPED"

var _icon: TextureRect
var _state_label: Label
var _detail_label: Label
var _state := ""

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	var layout := VBoxContainer.new()
	layout.name = "PapaFeedbackLayout"
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 6)
	add_child(layout)
	_icon = TextureRect.new()
	_icon.name = "PapaIcon"
	_icon.custom_minimum_size = Vector2(64.0, 64.0)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	layout.add_child(_icon)
	_state_label = Label.new()
	_state_label.name = "State"
	_state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(_state_label)
	_detail_label = Label.new()
	_detail_label.name = "Detail"
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.add_theme_font_size_override("font_size", 12)
	layout.add_child(_detail_label)

func set_objective_state(state: String, received_detail: String = "") -> void:
	var normalized_state := state.to_upper()
	if not _icon_state_is_supported(normalized_state):
		push_error("Estado visual de Papa no soportado: %s" % state)
		return
	_state = normalized_state
	_icon.texture = load(_icon_path(_state))
	_state_label.text = _state_label_text(_state)
	_detail_label.text = received_detail if not received_detail.is_empty() else "ESTADO RECIBIDO"

func get_state() -> String:
	return _state

func _icon_state_is_supported(state: String) -> bool:
	return state in [CAPTURED, TRANSPORTING, COOKING, RESCUED, ESCAPED]

func _icon_path(state: String) -> String:
	match state:
		CAPTURED:
			return CAPTURED_ICON
		TRANSPORTING:
			return TRANSPORTING_ICON
		COOKING:
			return COOKING_ICON
		RESCUED:
			return RESCUED_ICON
		ESCAPED:
			return ESCAPED_ICON
		_:
			return CAPTURED_ICON

func _state_label_text(state: String) -> String:
	match state:
		CAPTURED:
			return "PAPA CAPTURADA"
		TRANSPORTING:
			return "PAPA TRANSPORTADA"
		COOKING:
			return "PAPA EN OLLA · COCINÁNDOSE"
		RESCUED:
			return "PAPA RESCATADA"
		ESCAPED:
			return "PAPA ESCAPADA"
		_:
			return "PAPA · SIN ESTADO"
