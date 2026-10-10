extends Node2D

const MAP_SCENE := preload("res://scenes/map/papoi_map.tscn")

func _ready() -> void:
	var map := MAP_SCENE.instantiate() as PapoiMap
	if map == null:
		push_error("GK03 preview could not instantiate PapoiMap")
		return
	add_child(map)
	map.set_debug_overlay_visible(true)
	map.set_beast_gate_open(true, true)
