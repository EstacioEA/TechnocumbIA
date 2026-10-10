class_name PapoiLocalCamera
extends Camera2D

@export_category("Camera")
@export var follow_target: Node2D
@export var follow_smoothing: float = 8.0
@export var camera_zoom: Vector2 = Vector2.ONE
@export var only_follow_local_player: bool = true

@export_category("Map limits")
@export var map_bounds: Rect2 = Rect2(0.0, 0.0, 1920.0, 1080.0)

func _ready() -> void:
	if only_follow_local_player and not _parent_has_local_control():
		enabled = false
		return
	zoom = camera_zoom
	position_smoothing_enabled = follow_smoothing > 0.0
	position_smoothing_speed = follow_smoothing
	_apply_map_limits()
	_assign_target_if_needed()

func _process(_delta: float) -> void:
	if is_instance_valid(follow_target):
		global_position = follow_target.global_position

func _assign_target_if_needed() -> void:
	if is_instance_valid(follow_target):
		return
	var parent_node := get_parent()
	if parent_node is Node2D:
		follow_target = parent_node

func _parent_has_local_control() -> bool:
	var parent_node := get_parent()
	if parent_node == null:
		return false
	var local_control: Variant = parent_node.get("local_control_enabled")
	return local_control == null or bool(local_control)

func _apply_map_limits() -> void:
	limit_left = int(map_bounds.position.x)
	limit_top = int(map_bounds.position.y)
	limit_right = int(map_bounds.end.x)
	limit_bottom = int(map_bounds.end.y)
	limit_smoothed = false

func set_map_bounds(new_bounds: Rect2) -> void:
	map_bounds = new_bounds
	_apply_map_limits()

func set_local_active(active: bool) -> void:
	enabled = active
	if active:
		make_current()
