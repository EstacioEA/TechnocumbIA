extends Node2D

const CORRIDOR_FILL := Color("#00E5FF", 0.24)
const CORRIDOR_EDGE := Color("#00FFFF", 0.95)
const BLOCKER_FILL := Color("#FF1744", 0.55)
const BLOCKER_EDGE := Color("#FFEBEE", 0.95)
const CONNECTION_FILL := Color("#76FF03", 0.38)

func _ready() -> void:
	z_index = 20
	queue_redraw()

func _draw() -> void:
	for corridor in PapoiMap.PLAYABLE_CORRIDORS:
		draw_rect(corridor, CORRIDOR_FILL, true)
		draw_rect(corridor, CORRIDOR_EDGE, false, 3.0)

	for blocker in PapoiMap.PLAYABLE_BLOCKERS:
		draw_rect(blocker, BLOCKER_FILL, true)
		draw_rect(blocker, BLOCKER_EDGE, false, 2.0)

	_draw_connection_overlap(Rect2(96.0, 260.0, 256.0, 50.0))
	_draw_connection_overlap(Rect2(970.0, 342.0, 140.0, 40.0))
	_draw_connection_overlap(Rect2(820.0, 490.0, 300.0, 130.0))
	_draw_connection_overlap(Rect2(1130.0, 550.0, 124.0, 62.0))

func _draw_connection_overlap(rectangle: Rect2) -> void:
	draw_rect(rectangle, CONNECTION_FILL, true)
	draw_rect(rectangle, Color("#B2FF59"), false, 3.0)
