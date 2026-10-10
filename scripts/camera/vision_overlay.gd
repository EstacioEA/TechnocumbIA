class_name PapoiVisionOverlay
extends CanvasLayer

@export_category("Vision")
@export_range(0.1, 1.0, 0.05) var visible_field_ratio: float = 0.8
@export var overlay_color: Color = Color(0.015, 0.02, 0.03, 0.88)
@export var target: Node2D
@export var only_for_local_player: bool = true

@onready var overlay_rect: ColorRect = %OverlayRect

func _ready() -> void:
	if only_for_local_player and not _parent_has_local_control():
		layer = -1
		return
	layer = 20
	if not is_instance_valid(target):
		var parent_node := get_parent()
		if parent_node is Node2D:
			target = parent_node
	overlay_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_rect.color = overlay_color
	_update_shader_parameters()

func _process(_delta: float) -> void:
	_update_shader_parameters()

func set_target(new_target: Node2D) -> void:
	target = new_target

func _parent_has_local_control() -> bool:
	var parent_node := get_parent()
	if parent_node == null:
		return false
	var local_control := parent_node.get("local_control_enabled")
	return local_control == null or bool(local_control)

func _update_shader_parameters() -> void:
	if not overlay_rect.material is ShaderMaterial:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var target_position := viewport_size * 0.5
	if is_instance_valid(target):
		target_position = get_viewport().get_canvas_transform() * target.global_position

	var normalized_position := Vector2(
		target_position.x / viewport_size.x,
		target_position.y / viewport_size.y
	)
	var radius := visible_field_ratio * 0.5
	var shader_material := overlay_rect.material as ShaderMaterial
	shader_material.set_shader_parameter("vision_center", normalized_position)
	shader_material.set_shader_parameter("vision_radius", radius)
