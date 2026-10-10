class_name PapoiPlayerController
extends CharacterBody2D

signal movement_intent(direction: Vector2)

@export_category("Movement")
@export var move_speed: float = 180.0
@export var local_control_enabled: bool = true
@export var allow_local_prediction: bool = true

@export_category("Input")
@export var move_up_action: StringName = &"move_up"
@export var move_down_action: StringName = &"move_down"
@export var move_left_action: StringName = &"move_left"
@export var move_right_action: StringName = &"move_right"

func _ready() -> void:
	_register_default_input_actions()

func _physics_process(_delta: float) -> void:
	if not local_control_enabled:
		return

	var input_direction := Input.get_vector(
		move_left_action,
		move_right_action,
		move_up_action,
		move_down_action
	)
	movement_intent.emit(input_direction)

	# The client only produces intent. Prediction is optional and never changes
	# the authoritative state received from the host.
	if allow_local_prediction or is_multiplayer_authority():
		velocity = input_direction * move_speed
		move_and_slide()

func apply_authoritative_velocity(authoritative_velocity: Vector2) -> void:
	velocity = authoritative_velocity
	move_and_slide()

func set_local_control(enabled: bool) -> void:
	local_control_enabled = enabled

func _register_default_input_actions() -> void:
	_add_key_action(move_up_action, KEY_W)
	_add_key_action(move_down_action, KEY_S)
	_add_key_action(move_left_action, KEY_A)
	_add_key_action(move_right_action, KEY_D)

func _add_key_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		var key_event := InputEventKey.new()
		key_event.physical_keycode = keycode
		InputMap.action_add_event(action, key_event)
