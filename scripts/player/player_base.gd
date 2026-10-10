class_name PapoiPlayerBase
extends CharacterBody2D

@export_category("Collision")
@export var collision_radius: float = 18.0

func _ready() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		push_error("PapoiPlayerBase requiere un hijo CollisionShape2D.")
		return
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		push_error("PapoiPlayerBase requiere un CircleShape2D.")
		return
	circle_shape.radius = maxf(0.1, collision_radius)

func reset_motion() -> void:
	velocity = Vector2.ZERO
