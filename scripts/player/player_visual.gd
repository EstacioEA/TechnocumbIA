class_name PapoiPlayerVisual
extends Node2D

enum Team {
	ATTACKERS,
	DEFENDERS,
}

@export var team: Team = Team.ATTACKERS
@export var silhouette_radius: float = 22.0
@export var show_local_marker: bool = true
@export var role: StringName = &""

const ATTACKER_COLOR := Color("#B62A2A")
const DEFENDER_COLOR := Color("#2E9CC1")
const OUTLINE_COLOR := Color("#21161E")
const HIGHLIGHT_COLOR := Color("#F6B951")
const SPRITE_SCALE := Vector2(0.42, 0.42)

var _avatar: Sprite2D
var _avatar_role: StringName = &""

const ROLE_TEXTURES := {
	&"Papa": "res://assets/characteres/papa/papa_sprites.jpeg",
	&"Trolazzo": "res://assets/characteres/trolazo/trolazo_sprites.png",
	&"Bestia": "res://assets/characteres/bestia/bestia_sprites.png",
	&"Tanque": "res://assets/characteres/defensora/defensora_sprites.png",
	&"Cazador": "res://assets/characteres/cazador/cazador_sprites.jpeg",
	&"Porta Papas": "res://assets/characteres/porta_papa/porta_papa_sprites.png",
}

func _ready() -> void:
	_create_avatar()
	queue_redraw()

func _process(_delta: float) -> void:
	var parent_node := get_parent()
	if parent_node == null:
		return
	var parent_role: Variant = parent_node.get("role")
	if parent_role is StringName and parent_role != role:
		role = parent_role
	_update_avatar()
	var movement: Variant = parent_node.get("velocity")
	if movement is Vector2 and (movement as Vector2).length_squared() > 0.01:
		rotation = (movement as Vector2).angle()
	var local_control: Variant = parent_node.get("local_control_enabled")
	show_local_marker = local_control == null or bool(local_control)
	queue_redraw()

func _draw() -> void:
	var color := ATTACKER_COLOR if team == Team.ATTACKERS else DEFENDER_COLOR
	var radius := maxf(silhouette_radius, 8.0)
	if _avatar == null or not _avatar.visible:
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
	var marker_radius := maxf(radius, 28.0) if _avatar != null and _avatar.visible else radius
	draw_arc(Vector2.ZERO, marker_radius + 5.0, 0.0, TAU, 32, marker_color, 2.0, true)
	if show_local_marker:
		var marker := PackedVector2Array([
			Vector2(marker_radius + 8.0, 0.0),
			Vector2(marker_radius + 3.0, -4.0),
			Vector2(marker_radius + 3.0, 4.0),
		])
		draw_colored_polygon(marker, marker_color)

func _create_avatar() -> void:
	_avatar = Sprite2D.new()
	_avatar.name = "RoleAvatar"
	_avatar.centered = true
	_avatar.scale = SPRITE_SCALE
	_avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_avatar.material = _create_sprite_material()
	add_child(_avatar)
	_update_avatar()

func _update_avatar() -> void:
	if _avatar == null or _avatar_role == role:
		return
	_avatar_role = role
	var texture_path: String = ROLE_TEXTURES.get(role, "")
	if texture_path.is_empty():
		_avatar.texture = null
		_avatar.visible = false
		queue_redraw()
		return
	var sheet := load(texture_path) as Texture2D
	if sheet == null:
		push_error("No se pudo cargar el sprite del rol %s." % role)
		_avatar.visible = false
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0.0, 0.0, sheet.get_width() / 10.0, sheet.get_height() / 4.0)
	_avatar.texture = atlas
	_avatar.visible = true
	queue_redraw()

func _create_sprite_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 sampled = texture(TEXTURE, UV);
	float spread = max(sampled.r, max(sampled.g, sampled.b)) -
		min(sampled.r, min(sampled.g, sampled.b));
	float luminance = dot(sampled.rgb, vec3(0.299, 0.587, 0.114));
	bool checker = spread < 0.04 &&
		((luminance > 0.43 && luminance < 0.59) ||
		(luminance > 0.68 && luminance < 0.84));
	if (checker) {
		discard;
	}
	COLOR = sampled;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material
