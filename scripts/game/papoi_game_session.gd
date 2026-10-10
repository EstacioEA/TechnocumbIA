extends Node2D
class_name PapoiGameSession

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const MatchStateData = preload("res://scripts/game/match_state.gd")
const PlayerScene = preload("res://scenes/player/player.tscn")
const PapaCaptureStateData = preload("res://scripts/combat/papa_capture_state.gd")
const CombatLivesStateData = preload("res://scripts/combat/combat_lives_state.gd")
const BeastAccessStateData = preload("res://scripts/combat/beast_access_state.gd")
const CookingEscapeData = preload("res://scripts/objectives/papoi_cooking_escape.gd")
const TowerKeyStateData = preload("res://scripts/objectives/tower_key_state.gd")
const TOWER_KEY_TEXTURE = preload("res://assets/objects/tower_key.png")

const PAPA_OBJECT_ID := 10001
const PLAYER_MOVE_SPEED := 180.0
const CAPTURE_DISTANCE := 52.0
const HIT_DISTANCE := 48.0
const KEY_INTERACTION_DISTANCE := 52.0
const SNAPSHOT_INTERVAL_SECONDS := 0.1

@onready var _game_state: Node = $GameState
@onready var _map: Node2D = $Map
@onready var _hud: Node = $HUD

var _network_manager: Node
var _player_nodes: Dictionary = {}
var _movement_directions: Dictionary = {}
var _capture_state: Variant
var _lives_state: Variant
var _beast_state: Variant
var _cooking_flow: Variant
var _tower_key_state: Variant
var _papa_marker: Polygon2D
var _tower_key_marker: Sprite2D
var _snapshot_dirty := false
var _snapshot_elapsed := 0.0
var _last_remote_revision := -1
var _round_models_ready := false
var _suppress_snapshot_rpc := false
var _suppress_flow_sync := false
var _network_session_ended := false
var _local_preview_mode := false


func configure_network_manager(manager: Node) -> void:
	_network_manager = manager


func enable_local_preview_mode() -> void:
	_local_preview_mode = true


func _ready() -> void:
	_game_state.state_changed.connect(_on_authoritative_state_changed)
	_game_state.round_started.connect(_on_round_started)
	_game_state.round_finished.connect(_on_round_finished)
	_game_state.match_finished.connect(_on_match_finished)
	_register_game_input()
	_create_papa_marker()
	_create_tower_key_marker()
	if _network_manager != null:
		_network_manager.peer_left.connect(_on_peer_left)
		_network_manager.status_changed.connect(_on_network_status_changed)
		if _is_active_server():
			_begin_network_match.call_deferred()


func start_from_lobby_roster(roster: Array[Dictionary]) -> bool:
	if not _is_active_server():
		return false
	if not _game_state.configure_lobby(roster):
		return false
	if _local_preview_mode:
		var preview_state: Variant = _game_state.get("_state")
		if preview_state != null:
			preview_state.attacking_team = GameEnums.TeamSide.TEAM_A
	return _game_state.start_match()


func request_host_action(peer_id: int, action: StringName) -> bool:
	if not _is_active_server():
		return false
	return _perform_validated_action(peer_id, action)


func get_game_state() -> Node:
	return _game_state


func get_player_node(peer_id: int) -> Node2D:
	return _player_nodes.get(peer_id) as Node2D


func _begin_network_match() -> void:
	# Let every peer finish instantiating this RPC endpoint after lobby_start.
	await get_tree().create_timer(0.25).timeout
	if not is_inside_tree() or _network_manager == null or not _is_active_server():
		return
	var roster: Array[Dictionary] = []
	for entry: Dictionary in _network_manager.get_lobby_snapshot():
		roster.append({"peer_id": int(entry["id"]), "ready": bool(entry["ready"])})
	if not start_from_lobby_roster(roster):
		_hud.set_connection_status(false, "No se pudo iniciar el estado autoritativo de partida.")
		return
	_publish_snapshot()


func _process(delta: float) -> void:
	if not _is_active_server():
		return
	if _capture_state != null:
		_capture_state.tick(delta)
	if _lives_state != null:
		_lives_state.tick(delta)
	if _beast_state != null:
		_beast_state.tick(delta)
	_snapshot_elapsed += delta
	if _snapshot_dirty and _snapshot_elapsed >= SNAPSHOT_INTERVAL_SECONDS:
		_snapshot_elapsed = 0.0
		_publish_snapshot()


func _physics_process(delta: float) -> void:
	if not _is_active_server():
		return
	for peer_id_variant: Variant in _movement_directions:
		var peer_id := int(peer_id_variant)
		if peer_id == multiplayer.get_unique_id():
			continue # The host's local PlayerController applies its own movement.
		var player: CharacterBody2D = _player_nodes.get(peer_id) as CharacterBody2D
		if player == null:
			continue
		player.velocity = _movement_directions[peer_id] * PLAYER_MOVE_SPEED
		var previous_position := player.global_position
		player.move_and_slide()
		if not _map.is_position_in_playable_route(player.global_position):
			player.global_position = previous_position
			player.velocity = Vector2.ZERO
	if _capture_state != null and _capture_state.carrier_id > 0:
		var carrier := get_player_node(int(_capture_state.carrier_id))
		if carrier != null and _capture_state.papa_state == GameEnums.PapaState.CAPTURED:
			_papa_marker.global_position = carrier.global_position + Vector2(0.0, -24.0)
		elif _game_state.get_snapshot().papa_state in [GameEnums.PapaState.BEING_COOKED, GameEnums.PapaState.COOKED]:
			_papa_marker.global_position = _map.to_global(_map.POT_ROOM_CENTER)
	_schedule_snapshot()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action_pressed("papoi_interact"):
		_submit_action(&"interact")
	elif event.is_action_pressed("papoi_drop"):
		_submit_action(&"drop_papa")
	elif event.is_action_pressed("papoi_attack"):
		_submit_action(&"attack")
	elif event.is_action_pressed("papoi_rescue"):
		_submit_action(&"rescue")
	elif event.is_action_pressed("papoi_next_round"):
		_submit_action(&"next_round")


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _rpc_movement_intent(direction: Vector2) -> void:
	if not _is_active_server() or not _is_valid_direction(direction):
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not _player_nodes.has(sender_id):
		return
	_movement_directions[sender_id] = direction.limit_length(1.0)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_action_request(action: StringName, payload: Dictionary) -> void:
	if not _is_active_server() or not payload.is_empty():
		return
	var sender_id := multiplayer.get_remote_sender_id()
	if not _player_nodes.has(sender_id):
		return
	_perform_validated_action(sender_id, action)


@rpc("authority", "call_remote", "reliable")
func _rpc_receive_match_snapshot(snapshot: Dictionary) -> void:
	if _is_active_server() or not _is_transport_connected():
		return
	var validated: Variant = MatchStateData.from_dictionary(snapshot)
	if validated == null or validated.revision <= _last_remote_revision:
		return
	_last_remote_revision = validated.revision
	_render_snapshot(snapshot)


func _submit_action(action: StringName) -> void:
	if not _is_transport_connected():
		return
	var local_peer_id := multiplayer.get_unique_id()
	if _is_active_server():
		_perform_validated_action(local_peer_id, action)
	else:
		_rpc_action_request.rpc_id(1, action, {})


func _on_player_movement_intent(direction: Vector2, peer_id: int) -> void:
	if _is_active_server():
		_movement_directions[peer_id] = direction.limit_length(1.0)
	elif _is_transport_connected():
		_rpc_movement_intent.rpc_id(1, direction.limit_length(1.0))


func _perform_validated_action(peer_id: int, action: StringName) -> bool:
	if not _player_nodes.has(peer_id):
		return false
	if action == &"next_round" and peer_id != 1:
		return false
	var snapshot: Dictionary = _game_state.get_snapshot()
	var phase := int(snapshot.get("phase", GameEnums.GamePhase.LOBBY))
	match action:
		&"interact":
			if phase == GameEnums.GamePhase.ACTIVE:
				if _tower_key_state != null and _tower_key_state.request_collect(
					peer_id,
					_player_position(peer_id),
					int(_capture_state.carrier_id) if _capture_state != null else -1,
					KEY_INTERACTION_DISTANCE
				):
					_schedule_snapshot()
					return true
				if _tower_key_state != null and _map.is_position_in_beast_gate_access(_player_position(peer_id)) and _tower_key_state.request_open_tower(
					peer_id,
					_player_position(peer_id),
					_map.get_beast_gate_position(),
					INF
				):
					if _map.set_beast_gate_open(true, true):
						_schedule_snapshot()
						return true
					return false
				if _capture_state == null:
					return false
				if int(_capture_state.carrier_id) == peer_id:
					return _start_cooking_if_at_pot(peer_id)
				if int(_capture_state.carrier_id) < 0:
					return _capture_papa_if_near(peer_id)
			elif phase == GameEnums.GamePhase.POT_COOKING:
				return _rescue_papa(peer_id)
			elif phase == GameEnums.GamePhase.ESCAPE:
				return _finish_escape_if_at_base(peer_id)
			return false
		&"drop_papa":
			return _drop_papa(peer_id)
		&"attack":
			return _attack_nearby_attacker(peer_id)
		&"rescue":
			return _rescue_papa(peer_id)
		&"next_round":
			if phase != GameEnums.GamePhase.ROUND_RESULT:
				return false
			return _game_state.start_next_round()
	return false


func _capture_papa_if_near(peer_id: int) -> bool:
	var snapshot: Dictionary = _game_state.get_snapshot()
	if int(snapshot.phase) != GameEnums.GamePhase.ACTIVE or int(snapshot.papa_state) != GameEnums.PapaState.FREE:
		return false
	if not _is_attacker(peer_id) or _player_position(peer_id).distance_to(_papa_marker.global_position) > CAPTURE_DISTANCE:
		return false
	if _tower_key_state != null and int(_tower_key_state.key_holder_id) == peer_id:
		return false
	if _capture_state == null or not _capture_state.request_capture(peer_id):
		return false
	if not _game_state.capture_papa():
		_capture_state.request_drop(peer_id)
		return false
	_papa_marker.global_position = _player_position(peer_id) + Vector2(0.0, -24.0)
	_schedule_snapshot()
	return true


func _start_cooking_if_at_pot(peer_id: int) -> bool:
	if _capture_state == null or _cooking_flow == null:
		return false
	if int(_capture_state.carrier_id) != peer_id or not _map.is_position_in_pot(_player_position(peer_id)):
		return false
	_suppress_flow_sync = true
	var game_state_started: bool = _game_state.begin_pot_cooking()
	_suppress_flow_sync = false
	if not game_state_started:
		return false
	if not _cooking_flow.start_cooking(true):
		_suppress_flow_sync = true
		_game_state.cancel_pot_cooking()
		_suppress_flow_sync = false
		return false
	_papa_marker.global_position = _map.to_global(_map.POT_ROOM_CENTER)
	_schedule_snapshot()
	return true


func _finish_escape_if_at_base(peer_id: int) -> bool:
	if _cooking_flow == null or not _is_attacker(peer_id):
		return false
	if not _map.is_position_in_escape(_player_position(peer_id)):
		return false
	if not _game_state.register_escape(peer_id):
		return false
	_schedule_snapshot()
	return true


func _drop_papa(peer_id: int) -> bool:
	if _capture_state == null or int(_game_state.get_snapshot().phase) != GameEnums.GamePhase.ACTIVE:
		return false
	if not _is_attacker(peer_id):
		return false
	if int(_capture_state.carrier_id) != peer_id or not _capture_state.request_drop(peer_id):
		return false
	if not _game_state.register_attacker_hit(peer_id, true):
		return false
	_papa_marker.global_position = _player_position(peer_id)
	_schedule_snapshot()
	return true


func _attack_nearby_attacker(defender_id: int) -> bool:
	var snapshot: Dictionary = _game_state.get_snapshot()
	if int(snapshot.phase) not in [GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE]:
		return false
	if _is_attacker(defender_id):
		return false
	var defender_role := _role_for_peer(defender_id)
	if defender_role not in [GameEnums.DefenderRole.TROLAZZO, GameEnums.DefenderRole.BESTIA]:
		return false
	var target_id := -1
	var nearest_distance := HIT_DISTANCE
	for player_data: Dictionary in snapshot.players:
		var candidate_id := int(player_data.peer_id)
		if not _is_attacker(candidate_id):
			continue
		var distance := _player_position(defender_id).distance_to(_player_position(candidate_id))
		if distance <= nearest_distance:
			target_id = candidate_id
			nearest_distance = distance
	if target_id < 0:
		return false
	if int(_capture_state.carrier_id) == target_id:
		if not _capture_state.request_hit_carrier(target_id):
			return false
		_game_state.register_attacker_hit(target_id, true)
		_papa_marker.global_position = _player_position(target_id)
	else:
		if not _lives_state.request_hit_without_papa(target_id, false):
			return false
		_game_state.register_attacker_hit(target_id, false)
		if _tower_key_state != null:
			_tower_key_state.drop_at(_player_position(target_id), target_id)
	_schedule_snapshot()
	return true


func _rescue_papa(peer_id: int) -> bool:
	if _game_state.get_snapshot().phase != GameEnums.GamePhase.POT_COOKING:
		return false
	if _beast_state == null or peer_id != int(_beast_state.beast_id):
		return false
	if _role_for_peer(peer_id) != GameEnums.DefenderRole.BESTIA:
		return false
	if _player_position(peer_id).distance_to(_map.to_global(_map.POT_ROOM_CENTER)) > CAPTURE_DISTANCE:
		return false
	if _cooking_flow == null:
		return false
	_suppress_flow_sync = true
	var game_state_cancelled: bool = _game_state.cancel_pot_cooking()
	_suppress_flow_sync = false
	if not game_state_cancelled:
		return false
	if not _cooking_flow.sync_from_game_snapshot(_game_state.get_snapshot()):
		return false
	if _tower_key_state != null:
		_tower_key_state.spawn_at(_map.to_global(_map.TOWER_KEY_SPAWN))
	_papa_marker.global_position = _map.to_global(_map.POT_ROOM_CENTER)
	_schedule_snapshot()
	return true


func _on_cooking_completed(_papa_id: int) -> void:
	_schedule_snapshot()


func _on_cooking_cancelled(_papa_id: int) -> void:
	_schedule_snapshot()


func _on_authoritative_state_changed(snapshot: Dictionary) -> void:
	if not _is_active_server():
		return
	if _cooking_flow != null and not _suppress_flow_sync:
		_cooking_flow.sync_from_game_snapshot(snapshot)
	_ensure_player_nodes(snapshot)
	_render_snapshot(_compose_snapshot(snapshot))
	_schedule_snapshot()


func _on_round_started(_round_number: int, snapshot: Dictionary) -> void:
	if not _is_active_server():
		return
	_configure_round_models(snapshot)
	_reset_player_positions(snapshot)
	_publish_snapshot()


func _configure_round_models(snapshot: Dictionary) -> void:
	var player_ids: Array[int] = []
	var attacker_ids: Array[int] = []
	var defender_ids: Array[int] = []
	var porta_papas_ids: Array[int] = []
	for player: Dictionary in snapshot.players:
		var peer_id := int(player.peer_id)
		player_ids.append(peer_id)
		if player.get("side", "") == "attacker":
			attacker_ids.append(peer_id)
			if int(player.get("passive", -1)) == GameEnums.AttackerPassive.PORTA_PAPAS:
				porta_papas_ids.append(peer_id)
		else:
			defender_ids.append(peer_id)
	for player: Dictionary in snapshot.players:
		if int(player.get("role", -1)) == GameEnums.DefenderRole.BESTIA:
			var beast_id := int(player.peer_id)
			defender_ids.erase(beast_id)
			defender_ids.push_front(beast_id)
			break
	_capture_state = PapaCaptureStateData.new(true)
	_lives_state = CombatLivesStateData.new(true)
	_beast_state = BeastAccessStateData.new(true)
	_tower_key_state = TowerKeyStateData.new(true)
	_map.set_beast_gate_open(false, true)
	if not _capture_state.configure_round(PAPA_OBJECT_ID, attacker_ids, porta_papas_ids):
		_push_integration_error("PapaCaptureState rechazó la configuración de ronda.")
		return
	if not _lives_state.start_round(player_ids, attacker_ids):
		_push_integration_error("CombatLivesState rechazó la configuración de ronda.")
		return
	if not _beast_state.configure_round(defender_ids, attacker_ids):
		_push_integration_error("BeastAccessState rechazó la configuración de ronda.")
		return
	if not _tower_key_state.configure_round(attacker_ids):
		_push_integration_error("TowerKeyState rechazó la configuración de ronda.")
		return
	if not _tower_key_state.spawn_at(_map.to_global(_map.TOWER_KEY_SPAWN)):
		_push_integration_error("TowerKeyState no pudo colocar la llave inicial.")
		return
	_cooking_flow = CookingEscapeData.new(true, _capture_state, _beast_state)
	_cooking_flow.cooking_completed.connect(_on_cooking_completed)
	_cooking_flow.cooking_cancelled.connect(_on_cooking_cancelled)
	_round_models_ready = true


func _ensure_player_nodes(snapshot: Dictionary) -> void:
	if snapshot.get("players", []).size() != GameStateRequiredPlayers:
		return
	var spawn_points: Dictionary = _map.get_spawn_points()
	var attackers: Array = spawn_points["attackers"]
	var defenders: Array = spawn_points["defenders"]
	var attacker_index := 0
	var defender_index := 0
	var local_peer_id := multiplayer.get_unique_id() if _is_transport_connected() else -1
	for player: Dictionary in snapshot.players:
		var peer_id := int(player.get("peer_id", -1))
		if peer_id <= 0 or _player_nodes.has(peer_id) or not player.has("side"):
			continue
		var actor := PlayerScene.instantiate() as CharacterBody2D
		actor.name = "Player_%d" % peer_id
		actor.set_multiplayer_authority(1)
		actor.set("local_control_enabled", peer_id == local_peer_id)
		actor.set("allow_local_prediction", true)
		actor.set("enforce_playable_routes", true)
		actor.set("playable_routes_provider", _map)
		var side := str(player.get("side", "defender"))
		if side == "attacker":
			actor.position = attackers[attacker_index % attackers.size()]
			attacker_index += 1
		else:
			actor.position = defenders[defender_index % defenders.size()]
			defender_index += 1
		actor.movement_intent.connect(_on_player_movement_intent.bind(peer_id))
		_map.add_child(actor)
		_player_nodes[peer_id] = actor
		_add_player_visual(actor, peer_id, side)
		var camera := actor.get_node_or_null("LocalCamera") as Camera2D
		if camera != null:
			var is_local_player := peer_id == local_peer_id
			if camera.has_method("set_local_active"):
				camera.set_local_active(is_local_player)
			else:
				camera.enabled = is_local_player
			if camera.has_method("set_map_bounds"):
				camera.set_map_bounds(_map.get_map_bounds())
			else:
				camera.set("map_bounds", _map.get_map_bounds())
			if is_local_player:
				camera.set("camera_zoom", Vector2(1.5, 1.5))
				camera.set("zoom", Vector2(1.5, 1.5))
		var vision := actor.get_node_or_null("VisionOverlay") as CanvasLayer
		if vision != null:
			var is_local_player := peer_id == local_peer_id
			vision.set("layer", 20 if is_local_player else -1)
			if vision.has_method("set_target"):
				vision.call("set_target", actor)


func _add_player_visual(actor: Node2D, peer_id: int, side: String) -> void:
	var token := Polygon2D.new()
	token.name = "PlayerToken"
	token.polygon = _circle_polygon(17.0, 20)
	token.color = Color("#41c9bd") if side == "attacker" else Color("#e89b61")
	token.visible = false
	actor.add_child(token)
	var label := Label.new()
	label.name = "PeerLabel"
	label.text = "P%d" % peer_id
	label.position = Vector2(-16.0, -42.0)
	label.add_theme_font_size_override("font_size", 12)
	actor.add_child(label)


func _create_papa_marker() -> void:
	_papa_marker = Polygon2D.new()
	_papa_marker.name = "PapaToken"
	_papa_marker.polygon = _circle_polygon(13.0, 20)
	_papa_marker.color = Color("#f6df70")
	var spawn_points: Dictionary = _map.get_spawn_points()
	_papa_marker.position = spawn_points["papa"]
	_map.add_child(_papa_marker)
	var label := Label.new()
	label.text = "PAPA"
	label.position = Vector2(-22.0, -38.0)
	label.add_theme_font_size_override("font_size", 13)
	_papa_marker.add_child(label)


func _create_tower_key_marker() -> void:
	_tower_key_marker = Sprite2D.new()
	_tower_key_marker.name = "TowerKeyToken"
	_tower_key_marker.texture = TOWER_KEY_TEXTURE
	_tower_key_marker.scale = Vector2(0.12, 0.12)
	_tower_key_marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tower_key_marker.z_index = 3
	_tower_key_marker.visible = false
	_map.add_child(_tower_key_marker)


func _visual_role_for_player(player: Dictionary) -> StringName:
	if player.get("side", "") == "attacker":
		match int(player.get("passive", -1)):
			GameEnums.AttackerPassive.TANQUE:
				return &"Tanque"
			GameEnums.AttackerPassive.CAZADOR:
				return &"Cazador"
			GameEnums.AttackerPassive.PORTA_PAPAS:
				return &"Porta Papas"
	else:
		match int(player.get("role", -1)):
			GameEnums.DefenderRole.PAPA:
				return &"Papa"
			GameEnums.DefenderRole.TROLAZZO:
				return &"Trolazzo"
			GameEnums.DefenderRole.BESTIA:
				return &"Bestia"
	return &""


func _circle_polygon(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _reset_player_positions(snapshot: Dictionary) -> void:
	var spawn_points: Dictionary = _map.get_spawn_points()
	var attackers: Array = spawn_points["attackers"]
	var defenders: Array = spawn_points["defenders"]
	var attacker_index := 0
	var defender_index := 0
	for player: Dictionary in snapshot.players:
		var peer_id := int(player.peer_id)
		var actor := get_player_node(peer_id)
		if actor == null:
			continue
		if player.get("side", "") == "attacker":
			actor.position = attackers[attacker_index % attackers.size()]
			attacker_index += 1
		else:
			actor.position = defenders[defender_index % defenders.size()]
			defender_index += 1
		if actor is CharacterBody2D:
			actor.velocity = Vector2.ZERO
		var token := actor.get_node_or_null("PlayerToken") as Polygon2D
		if token != null:
			token.visible = false
	_papa_marker.position = spawn_points["papa"]


func _compose_snapshot(source: Dictionary) -> Dictionary:
	var snapshot := source.duplicate(true)
	for player: Dictionary in snapshot.get("players", []):
		var peer_id := int(player.get("peer_id", -1))
		# Role/passive come from GameState. Cooldowns are copied only from the
		# host-side combat model that owns them; unsupported roles stay unavailable.
		var player_cooldowns: Dictionary = {}
		if _beast_state != null and peer_id == int(_beast_state.beast_id) \
			and int(player.get("role", -1)) == GameEnums.DefenderRole.BESTIA:
			var beast_snapshot: Dictionary = _beast_state.get_snapshot()
			var beast_cooldowns: Variant = beast_snapshot.get("cooldowns", {})
			if beast_cooldowns is Dictionary:
				player_cooldowns = beast_cooldowns.duplicate(true)
		player["cooldowns"] = player_cooldowns
		var actor := get_player_node(peer_id)
		if actor != null:
			player["position"] = actor.global_position
		if _lives_state != null:
			var combat_snapshot: Dictionary = _lives_state.get_player_state(peer_id)
			if not combat_snapshot.is_empty():
				player["lives"] = int(combat_snapshot.get("lives", player.get("lives", 0)))
				player["active"] = bool(combat_snapshot.get("active", true))
				player["respawn_remaining"] = float(combat_snapshot.get("respawn_remaining", 0.0))
	if _capture_state != null:
		snapshot["papa_carrier_id"] = int(_capture_state.carrier_id)
		snapshot["papa_immobilized_remaining"] = float(_capture_state.immobilized_remaining)
		snapshot["papa_position"] = _papa_marker.global_position
	if _tower_key_state != null:
		var key_snapshot: Dictionary = _tower_key_state.get_snapshot()
		snapshot["tower_key_visible"] = bool(key_snapshot.key_visible)
		snapshot["tower_key_holder_id"] = int(key_snapshot.key_holder_id)
		snapshot["tower_key_position"] = key_snapshot.key_position
		snapshot["tower_open"] = bool(key_snapshot.tower_open)
	return snapshot


func _render_snapshot(snapshot: Dictionary) -> void:
	_ensure_player_nodes(snapshot)
	var escape_indicator := _map.get_node_or_null("EscapeExitIndicator")
	if escape_indicator != null and escape_indicator.has_method("set_escape_available"):
		escape_indicator.call("set_escape_available", bool(snapshot.get("escape_available", false)))
	var local_snapshot := snapshot.duplicate(true)
	local_snapshot["local_peer_id"] = multiplayer.get_unique_id() if _is_transport_connected() else -1
	_hud.apply_match_snapshot(local_snapshot)
	for player: Dictionary in snapshot.get("players", []):
		var actor := get_player_node(int(player.get("peer_id", -1)))
		if actor != null and player.get("position") is Vector2:
			actor.global_position = player["position"]
		if actor != null:
			var visual := actor.get_node_or_null("PlayerVisual") as Node2D
			if visual != null:
				visual.set("team", 0 if player.get("side", "") == "attacker" else 1)
				visual.set("role", _visual_role_for_player(player))
	if _papa_marker != null:
		if snapshot.get("papa_position") is Vector2:
			_papa_marker.global_position = snapshot["papa_position"]
		elif int(snapshot.get("papa_state", GameEnums.PapaState.FREE)) == GameEnums.PapaState.FREE:
			_papa_marker.position = _map.get_spawn_points()["papa"]
	if _tower_key_marker != null:
		var key_visible := bool(snapshot.get("tower_key_visible", false))
		_tower_key_marker.visible = key_visible
		if key_visible and snapshot.get("tower_key_position") is Vector2:
			_tower_key_marker.global_position = snapshot["tower_key_position"]
		if bool(snapshot.get("tower_open", false)):
			_map.apply_beast_gate_state(true)


func _schedule_snapshot() -> void:
	if _is_active_server():
		_snapshot_dirty = true


func _publish_snapshot() -> void:
	if not _is_active_server():
		return
	var snapshot: Dictionary = _compose_snapshot(_game_state.get_snapshot())
	_render_snapshot(snapshot)
	_snapshot_dirty = false
	_snapshot_elapsed = 0.0
	if _suppress_snapshot_rpc:
		return
	if _is_transport_connected() and multiplayer.get_peers().size() > 0:
		_rpc_receive_match_snapshot.rpc(snapshot)


func _on_round_finished(_winner: int, _reason: int, _snapshot: Dictionary) -> void:
	_publish_snapshot()


func _on_match_finished(_winner: int, _snapshot: Dictionary) -> void:
	_publish_snapshot()


func _on_peer_left(peer_id: int) -> void:
	if not _is_active_server() or _game_state == null:
		return
	_suppress_snapshot_rpc = true
	var phase := int(_game_state.get_snapshot().phase)
	if phase in [GameEnums.GamePhase.COUNTDOWN, GameEnums.GamePhase.ACTIVE, GameEnums.GamePhase.POT_COOKING, GameEnums.GamePhase.ESCAPE]:
		_game_state.resolve_round(-1, GameEnums.RoundEndReason.DISCONNECT)
	else:
		_hud.set_connection_status(false, "Se desconectó el jugador %d." % peer_id)
	_flush_disconnect_snapshot.call_deferred()


func _flush_disconnect_snapshot() -> void:
	await get_tree().create_timer(0.1).timeout
	_suppress_snapshot_rpc = false
	_publish_snapshot()


func _on_network_status_changed(message: String) -> void:
	if _hud != null:
		var connected := _is_transport_connected()
		_hud.set_connection_status(connected, message)
		if not connected:
			_network_session_ended = true


func _is_transport_connected() -> bool:
	if _local_preview_mode:
		return true
	if _network_session_ended or multiplayer.multiplayer_peer == null:
		return false
	return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _is_active_server() -> bool:
	if _local_preview_mode:
		return true
	return _is_transport_connected() and multiplayer.is_server()


func _player_position(peer_id: int) -> Vector2:
	var actor := get_player_node(peer_id)
	return actor.global_position if actor != null else Vector2.INF


func _is_attacker(peer_id: int) -> bool:
	for player: Dictionary in _game_state.get_snapshot().get("players", []):
		if int(player.get("peer_id", -1)) == peer_id:
			return player.get("side", "") == "attacker"
	return false


func _role_for_peer(peer_id: int) -> int:
	for player: Dictionary in _game_state.get_snapshot().get("players", []):
		if int(player.get("peer_id", -1)) == peer_id:
			return int(player.get("role", -1))
	return -1


func _register_game_input() -> void:
	_add_key_action("papoi_interact", KEY_E)
	_add_key_action("papoi_drop", KEY_Q)
	_add_key_action("papoi_attack", KEY_F)
	_add_key_action("papoi_rescue", KEY_R)
	_add_key_action("papoi_next_round", KEY_ENTER)


func _add_key_action(action_name: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not InputMap.action_get_events(action_name).is_empty():
		return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)


func _is_valid_direction(direction: Vector2) -> bool:
	return is_finite(direction.x) and is_finite(direction.y) and direction.length() <= 1.01


func _push_integration_error(message: String) -> void:
	push_error("PapoiGameSession: " + message)
	if _hud != null:
		_hud.set_connection_status(false, message)


const GameStateRequiredPlayers := 6
