class_name CooldownFeedback
extends Control

const READY_ICON := "res://assets/ui/feedback/cooldown_ready.svg"
const BLOCKED_ICON := "res://assets/ui/feedback/cooldown_blocked.svg"
const COUNTDOWN_ICON := "res://assets/ui/feedback/cooldown_countdown.svg"

const STATE_READY := "READY"
const STATE_BLOCKED := "BLOCKED"
const STATE_COUNTDOWN := "COUNTDOWN"

var _slots: Dictionary = {}
var _container: HBoxContainer

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	_container = HBoxContainer.new()
	_container.name = "CooldownSlots"
	_container.add_theme_constant_override("separation", 10)
	_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_container)

func set_cooldown_state(slot_name: String, state: String, received_time_text: String = "") -> void:
	if _container == null:
		push_error("CooldownFeedback no está listo para recibir estados.")
		return
	var normalized_state := state.to_upper()
	if normalized_state != STATE_READY and normalized_state != STATE_BLOCKED and normalized_state != STATE_COUNTDOWN:
		push_error("Estado de cooldown no soportado: %s" % state)
		return
	var card: VBoxContainer = _slots.get(slot_name)
	if card == null:
		card = _create_slot(slot_name)
		_slots[slot_name] = card
	var icon := card.get_node("Icon") as TextureRect
	var state_label := card.get_node("State") as Label
	var time_label := card.get_node("Time") as Label
	icon.texture = load(_icon_path(normalized_state))
	state_label.text = _state_label(normalized_state)
	time_label.text = received_time_text if not received_time_text.is_empty() else "TIEMPO RECIBIDO: —"

func _create_slot(slot_name: String) -> VBoxContainer:
	var card := VBoxContainer.new()
	card.name = slot_name
	card.custom_minimum_size = Vector2(128.0, 94.0)
	card.alignment = BoxContainer.ALIGNMENT_CENTER
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(32.0, 32.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.add_child(icon)
	var label := Label.new()
	label.name = "State"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(label)
	var time_label := Label.new()
	time_label.name = "Time"
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 11)
	card.add_child(time_label)
	_container.add_child(card)
	return card

func _icon_path(state: String) -> String:
	match state:
		STATE_READY:
			return READY_ICON
		STATE_BLOCKED:
			return BLOCKED_ICON
		STATE_COUNTDOWN:
			return COUNTDOWN_ICON
		_:
			return READY_ICON

func _state_label(state: String) -> String:
	match state:
		STATE_READY:
			return "DISPONIBLE"
		STATE_BLOCKED:
			return "BLOQUEADO"
		STATE_COUNTDOWN:
			return "CUENTA RECIBIDA"
		_:
			return "SIN ESTADO"
