extends Node2D

@export var vision_enabled: bool = true

func _ready() -> void:
	var players := [
		{"name": "AttackerOne", "team": 0, "role": &"Tanque", "local": true},
		{"name": "AttackerTwo", "team": 0, "role": &"Cazador", "local": false},
		{"name": "AttackerThree", "team": 0, "role": &"Porta Papas", "local": false},
		{"name": "DefenderOne", "team": 1, "role": &"Papa", "local": false},
		{"name": "DefenderTwo", "team": 1, "role": &"Trolazzo", "local": false},
		{"name": "DefenderThree", "team": 1, "role": &"Bestia", "local": false},
	]
	for player_data: Dictionary in players:
		var player := get_node_or_null(player_data["name"]) as Node2D
		if player == null:
			push_error("GV03 preview is missing %s" % player_data["name"])
			continue
		var visual := player.get_node_or_null("PlayerVisual") as Node2D
		if visual != null:
			visual.set("team", player_data["team"])
			visual.set("role", player_data["role"])
			visual.queue_redraw()
		var local_control: Variant = player.get("local_control_enabled")
		if local_control != player_data["local"]:
			player.set("local_control_enabled", player_data["local"])
		var camera := player.get_node_or_null("LocalCamera") as Camera2D
		if camera != null:
			camera.enabled = false
		var overlay := player.get_node_or_null("VisionOverlay") as CanvasLayer
		if overlay != null:
			overlay.layer = 20 if vision_enabled and player_data["local"] else -1
