extends Control

const FEEDBACK_SCENE := preload("res://scenes/ui/role_feedback.tscn")

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	var title := Label.new()
	title.text = "GM04 · HOJA DE PREVIEW · FEEDBACK DE EVENTOS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 20.0
	add_child(title)

	var note := Label.new()
	note.text = "REAL = señal recibida del host · SIMULADA = muestra visual.\nDesconexión no equivale a victoria."
	note.position = Vector2(40.0, 62.0)
	note.add_theme_font_size_override("font_size", 14)
	add_child(note)

	var real_feedback := FEEDBACK_SCENE.instantiate() as RoleFeedback
	real_feedback.position = Vector2(32.0, 130.0)
	real_feedback.size = Vector2(560.0, 150.0)
	add_child(real_feedback)
	real_feedback.present_event("IMPACT", "Golpe confirmado por el host.", "REAL")

	var simulated_feedback := FEEDBACK_SCENE.instantiate() as RoleFeedback
	simulated_feedback.position = Vector2(32.0, 310.0)
	simulated_feedback.size = Vector2(560.0, 150.0)
	add_child(simulated_feedback)
	simulated_feedback.present_event("DISCONNECT", "Jugador desconectado · muestra de preview.", "SIMULATED")
