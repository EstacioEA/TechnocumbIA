extends Control

const ROLE_ICONS := [
	{"name": "Papa", "path": "res://assets/ui/roles/papa.svg"},
	{"name": "Trolazzo", "path": "res://assets/ui/roles/trolazzo.svg"},
	{"name": "Bestia", "path": "res://assets/ui/roles/bestia.svg"},
	{"name": "Tanque", "path": "res://assets/ui/roles/tanque.svg"},
	{"name": "Cazador", "path": "res://assets/ui/roles/cazador.svg"},
	{"name": "Porta Papas", "path": "res://assets/ui/roles/porta_papas.svg"},
]

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	var title := Label.new()
	title.text = "GM01 · ICONOS DE ROLES Y PASIVAS · PREVIEW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 24.0
	add_child(title)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.set_anchors_preset(Control.PRESET_CENTER)
	grid.position = Vector2(-360.0, -150.0)
	grid.size = Vector2(720.0, 300.0)
	grid.add_theme_constant_override("h_separation", 28)
	grid.add_theme_constant_override("v_separation", 20)
	add_child(grid)

	for icon_data in ROLE_ICONS:
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(210.0, 135.0)
		card.alignment = BoxContainer.ALIGNMENT_CENTER
		var icon := TextureRect.new()
		icon.texture = load(icon_data.path)
		icon.custom_minimum_size = Vector2(64.0, 64.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		card.add_child(icon)
		var label := Label.new()
		label.text = icon_data.name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(label)
		grid.add_child(card)
