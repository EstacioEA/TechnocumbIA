extends Node

const MOVEMENT_TOLERANCE := 0.01

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	var required_actions := [&"move_up", &"move_down", &"move_left", &"move_right"]
	for action in required_actions:
		if not InputMap.has_action(action):
			push_error("Falta la accion de movimiento: %s" % action)
			get_tree().quit(1)
			return

	var initial_position: Vector2 = player.global_position
	Input.action_press(&"move_right")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(&"move_right")

	if player.global_position.x <= initial_position.x + MOVEMENT_TOLERANCE:
		push_error("El jugador no avanzo al presionar move_right.")
		get_tree().quit(1)
		return

	print("V02 movement test passed")
	get_tree().quit(0)
