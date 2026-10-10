class_name PapoiPlayerVisual
extends Node2D

enum Team {
	ATTACKERS,
	DEFENDERS,
}

@export var team: Team = Team.ATTACKERS
@export var silhouette_radius: float = 22.0
@export var show_local_marker: bool = true

const ATTACKER_COLOR := Color("#B62A2A")
const DEFENDER_COLOR := Color("#2E9CC1")
const OUTLINE_COLOR := Color("#21161E")
const HIGHLIGHT_COLOR := Color("#F6B951")

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return
	var movement: Variant = parent_node.get("velocity")
	if movement is Vector2 and (movement as Vector2).length_squared() > 0.01:
		rotation = (movement as Vector2).angle()
	var local_control: Variant = parent_node.get("local_control_enabled")
	show_local_marker = local_control == null or bool(local_control)
	queue_redraw()

func _draw() -> void:
	var color := ATTACKER_COLOR if team == Team.ATTACKERS else DEFENDER_COLOR
	var radius := maxf(silhouette_radius, 8.0)
	draw_circle(Vector2.ZERO, radius, OUTLINE_COLOR)
	draw_circle(Vector2.ZERO, radius - 3.0, color)

	if team == Team.ATTACKERS:
		var diamond := PackedVector2Array([
			Vector2(0.0, -radius * 0.7),
			Vector2(radius * 0.7, 0.0),
			Vector2(0.0, radius * 0.7),
			Vector2(-radius * 0.7, 0.0),
		])
		draw_colored_polygon(diamond, HIGHLIGHT_COLOR)
	else:
		var shield := PackedVector2Array([
			Vector2(0.0, -radius * 0.7),
			Vector2(radius * 0.55, -radius * 0.35),
			Vector2(radius * 0.45, radius * 0.45),
			Vector2(0.0, radius * 0.72),
			Vector2(-radius * 0.45, radius * 0.45),
			Vector2(-radius * 0.55, -radius * 0.35),
		])
		draw_colored_polygon(shield, HIGHLIGHT_COLOR)

	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, OUTLINE_COLOR, 2.0, true)
	var marker_color := HIGHLIGHT_COLOR if show_local_marker else Color("#9AA4B2")
	draw_arc(Vector2.ZERO, radius + 5.0, 0.0, TAU, 32, marker_color, 2.0, true)
	if show_local_marker:
		var marker := PackedVector2Array([
			Vector2(radius + 8.0, 0.0),
			Vector2(radius + 3.0, -4.0),
			Vector2(radius + 3.0, 4.0),
		])
		draw_colored_polygon(marker, marker_color)
