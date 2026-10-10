extends Node2D

func _ready() -> void:
	var defender_visual: Node2D = get_node("Defender/PlayerVisual")
	if defender_visual == null:
		push_error("GV01 preview requires Defender/PlayerVisual")
		return
	defender_visual.set("team", 1)
	defender_visual.queue_redraw()
