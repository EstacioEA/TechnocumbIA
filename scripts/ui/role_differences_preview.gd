extends Control

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const RoleContracts = preload("res://scripts/roles/role_contracts.gd")
const PapaCapture = preload("res://scripts/combat/papa_capture_state.gd")
const CombatLives = preload("res://scripts/combat/combat_lives_state.gd")
const BeastAccess = preload("res://scripts/combat/beast_access_state.gd")
const AbilitiesEnrage = preload("res://scripts/abilities/abilities_enrage_state.gd")

var _roles: RoleContracts
var _papa: PapaCapture
var _lives: CombatLives
var _beast: BeastAccess
var _abilities: AbilitiesEnrage
var _role_output: Label
var _papa_output: Label
var _lives_output: Label
var _beast_output: Label
var _abilities_output: Label
var _authority_output: Label

func _ready() -> void:
	theme = load("res://scenes/ui/papoi_theme.tres")
	_reset_all()
	_build_view()
	_refresh_all()

func _build_view() -> void:
	var margins := MarginContainer.new()
	margins.name = "PreviewMargins"
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 28)
	margins.add_theme_constant_override("margin_top", 20)
	margins.add_theme_constant_override("margin_right", 28)
	margins.add_theme_constant_override("margin_bottom", 20)
	add_child(margins)

	var main := VBoxContainer.new()
	main.name = "PreviewLayout"
	main.add_theme_constant_override("separation", 10)
	margins.add_child(main)

	var title := Label.new()
	title.text = "TC03 · PREVIEW INTERACTIVO DE ROLES Y PASIVAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	main.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Simulación local host-authoritativa · no es una partida LAN · usa los módulos reales"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	main.add_child(subtitle)

	var tabs := TabContainer.new()
	tabs.name = "FeatureTabs"
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(tabs)
	tabs.add_child(_build_roles_tab())
	tabs.add_child(_build_papa_tab())
	tabs.add_child(_build_lives_tab())
	tabs.add_child(_build_beast_tab())
	tabs.add_child(_build_abilities_tab())
	tabs.add_child(_build_authority_tab())

func _build_roles_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Roles"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Roles defensivos y pasivas atacantes")
	var assign_button := Button.new()
	assign_button.text = "ASIGNAR 3 ATACANTES + 3 DEFENSORES"
	assign_button.pressed.connect(_assign_roles)
	tab.add_child(assign_button)
	var reject_button := Button.new()
	reject_button.text = "PROBAR ASIGNACIÓN DESDE CLIENTE (DEBE RECHAZAR)"
	reject_button.pressed.connect(_try_client_role_assignment)
	tab.add_child(reject_button)
	_role_output = _add_output(tab)
	return tab

func _build_papa_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Papa"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Papa: captura, inmovilización, sprint, soltar y golpe")
	var row := _button_row(tab)
	_add_button(row, "Capturar", _capture_papa)
	_add_button(row, "Sprint Porta Papas", _sprint_papa)
	_add_button(row, "Soltar", _drop_papa)
	_add_button(row, "Golpear portador", _hit_papa_carrier)
	_add_button(row, "Reiniciar", _reset_papa)
	_papa_output = _add_output(tab)
	return tab

func _build_lives_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Vidas"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Vidas, golpe sin Papa y respawn")
	var row := _button_row(tab)
	_add_button(row, "Golpe sin Papa", _hit_without_papa)
	_add_button(row, "Avanzar 3 s", _advance_respawn)
	_add_button(row, "Golpe con Papa (rechazo)", _hit_with_papa)
	_add_button(row, "Reiniciar ronda", _reset_lives)
	_lives_output = _add_output(tab)
	return tab

func _build_beast_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Bestia"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Bestia: aparición, ataques, cooldown y acceso a olla")
	var row := _button_row(tab)
	_add_button(row, "Avanzar 30 s", _advance_beast)
	_add_button(row, "Ataque básico", _beast_basic)
	_add_button(row, "Ataque especial", _beast_special)
	_add_button(row, "Alternar cocción", _toggle_cooking)
	_add_button(row, "Reiniciar", _reset_beast)
	_beast_output = _add_output(tab)
	return tab

func _build_abilities_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Pasivas"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Trolazzo, Tanque, Cazador, Porta Papas y enfurecimiento")
	var row := _button_row(tab)
	_add_button(row, "Trampa Trolazzo", _place_trap)
	_add_button(row, "Consultar pasivas", _inspect_passives)
	_add_button(row, "Completar cocción", _complete_cooking)
	_add_button(row, "Reiniciar", _reset_abilities)
	_abilities_output = _add_output(tab)
	return tab

func _build_authority_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "Autoridad"
	tab.add_theme_constant_override("separation", 8)
	_add_heading(tab, "Pruebas negativas: un cliente no puede mutar la partida")
	var row := _button_row(tab)
	_add_button(row, "Probar cliente en roles", _try_client_roles)
	_add_button(row, "Probar cliente en Papa", _try_client_papa)
	_add_button(row, "Probar cliente en vidas", _try_client_lives)
	_add_button(row, "Probar cliente en Bestia", _try_client_beast)
	_add_button(row, "Probar cliente en pasivas", _try_client_abilities)
	_authority_output = _add_output(tab)
	return tab

func _reset_all() -> void:
	_roles = RoleContracts.new(true)
	_papa = PapaCapture.new(true)
	_papa.configure_round(10, [1, 2, 3], [1])
	_lives = CombatLives.new(true)
	_lives.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3])
	_beast = BeastAccess.new(true)
	_beast.configure_round([6, 5, 4], [1, 2, 3])
	_abilities = AbilitiesEnrage.new(true)
	_abilities.configure_round({
		4: GameEnums.DefenderRole.PAPA,
		5: GameEnums.DefenderRole.TROLAZZO,
		6: GameEnums.DefenderRole.BESTIA,
	}, {
		1: GameEnums.AttackerPassive.TANQUE,
		2: GameEnums.AttackerPassive.CAZADOR,
		3: GameEnums.AttackerPassive.PORTA_PAPAS,
	}, 6)

func _refresh_all() -> void:
	if _role_output:
		_role_output.text = "Pulsa ASIGNAR para ver los seis contratos."
	if _papa_output:
		_refresh_papa("Papa lista en estado FREE.")
	if _lives_output:
		_refresh_lives("Ronda iniciada con 3 vidas por atacante.")
	if _beast_output:
		_refresh_beast("Bestia configurada; todavía no aparece.")
	if _abilities_output:
		_refresh_abilities("Pasivas configuradas; Bestia no está enfurecida.")
	if _authority_output:
		_authority_output.text = "Cada botón debe mostrar RECHAZADO."

func _assign_roles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var assignments := _roles.assign_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6], rng)
	var lines: Array[String] = ["HOST ACEPTÓ · 6 CONTRATOS"]
	for assignment in assignments.players:
		var description := "Jugador %d · %s" % [
			int(assignment.peer_id),
			_role_or_passive_text(assignment),
		]
		lines.append(description)
	_role_output.text = "\n".join(lines)

func _try_client_role_assignment() -> void:
	var client := RoleContracts.new(false)
	var rng := RandomNumberGenerator.new()
	var result := client.assign_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6], rng)
	_role_output.text = "CLIENTE: %s" % ("RECHAZADO CORRECTAMENTE" if result.is_empty() else "ERROR: MUTACIÓN ACEPTADA")

func _capture_papa() -> void:
	_papa_output.text = "Captura: %s" % ("ACEPTADA" if _papa.request_capture(1) else "RECHAZADA")
	_refresh_papa(_papa_output.text)

func _sprint_papa() -> void:
	_papa_output.text = "Sprint Porta Papas: %s" % ("ACEPTADO" if _papa.request_porta_papas_sprint(1) else "RECHAZADO")
	_refresh_papa(_papa_output.text)

func _drop_papa() -> void:
	_papa_output.text = "Soltar Papa: %s" % ("ACEPTADO" if _papa.request_drop(1) else "RECHAZADO")
	_refresh_papa(_papa_output.text)

func _hit_papa_carrier() -> void:
	_papa_output.text = "Golpe al portador: %s" % ("ACEPTADO" if _papa.request_hit_carrier(1) else "RECHAZADO")
	_refresh_papa(_papa_output.text)

func _reset_papa() -> void:
	_papa = PapaCapture.new(true)
	_papa.configure_round(10, [1, 2, 3], [1])
	_refresh_papa("Papa reiniciada.")

func _hit_without_papa() -> void:
	var accepted := _lives.request_hit_without_papa(1, false)
	_refresh_lives("Golpe sin Papa: %s" % ("ACEPTADO · -1 vida" if accepted else "RECHAZADO"))

func _advance_respawn() -> void:
	_lives.tick(3.0)
	_refresh_lives("Reloj de respawn avanzado 3 s.")

func _hit_with_papa() -> void:
	var accepted := _lives.request_hit_without_papa(2, true)
	_refresh_lives("Golpe con Papa: %s" % ("ERROR" if accepted else "RECHAZADO · no quita vida"))

func _reset_lives() -> void:
	_lives = CombatLives.new(true)
	_lives.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3])
	_refresh_lives("Ronda reiniciada.")

func _advance_beast() -> void:
	_beast.tick(30.0)
	_refresh_beast("Reloj de aparición avanzado 30 s.")

func _beast_basic() -> void:
	_refresh_beast("Ataque básico: %s" % ("ACEPTADO" if _beast.request_basic_attack(1) else "RECHAZADO"))

func _beast_special() -> void:
	_refresh_beast("Ataque especial: %s" % ("ACEPTADO" if _beast.request_special_attack(1) else "RECHAZADO"))

func _toggle_cooking() -> void:
	var cooking := not _beast.pot_is_cooking
	_beast.set_pot_cooking(cooking)
	_refresh_beast("Cocción: %s" % ("ACTIVA" if cooking else "INACTIVA"))

func _reset_beast() -> void:
	_beast = BeastAccess.new(true)
	_beast.configure_round([6, 5, 4], [1, 2, 3])
	_refresh_beast("Bestia reiniciada.")

func _place_trap() -> void:
	_refresh_abilities("Trampa: %s" % ("ACEPTADA" if _abilities.request_trollazzo_trap(5, Vector2(300.0, 200.0)) else "RECHAZADA"))

func _inspect_passives() -> void:
	_refresh_abilities("Tanque %.2fx · Cazador %.2fx · Porta Papas -%.1fs" % [
		_abilities.get_trap_damage_multiplier(1),
		_abilities.get_beast_damage_multiplier(2),
		_abilities.get_porta_papas_sprint_reduction(3),
	])

func _complete_cooking() -> void:
	_refresh_abilities("Enfurecimiento: %s" % ("ACTIVADO" if _abilities.request_cooking_completed() else "RECHAZADO"))

func _reset_abilities() -> void:
	_abilities = AbilitiesEnrage.new(true)
	_abilities.configure_round({
		4: GameEnums.DefenderRole.PAPA,
		5: GameEnums.DefenderRole.TROLAZZO,
		6: GameEnums.DefenderRole.BESTIA,
	}, {
		1: GameEnums.AttackerPassive.TANQUE,
		2: GameEnums.AttackerPassive.CAZADOR,
		3: GameEnums.AttackerPassive.PORTA_PAPAS,
	}, 6)
	_refresh_abilities("Pasivas reiniciadas.")

func _try_client_roles() -> void:
	var client := RoleContracts.new(false)
	var result := client.assign_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6], RandomNumberGenerator.new())
	_authority_output.text = "Roles cliente: %s" % ("RECHAZADO" if result.is_empty() else "ERROR")

func _try_client_papa() -> void:
	var client := PapaCapture.new(false)
	_authority_output.text = "Papa cliente: %s" % ("RECHAZADO" if not client.configure_round(10, [1, 2, 3], [1]) else "ERROR")

func _try_client_lives() -> void:
	var client := CombatLives.new(false)
	_authority_output.text = "Vidas cliente: %s" % ("RECHAZADO" if not client.start_round([1, 2, 3], [1]) else "ERROR")

func _try_client_beast() -> void:
	var client := BeastAccess.new(false)
	_authority_output.text = "Bestia cliente: %s" % ("RECHAZADO" if not client.configure_round([6, 5, 4], [1, 2, 3]) else "ERROR")

func _try_client_abilities() -> void:
	var client := AbilitiesEnrage.new(false)
	_authority_output.text = "Pasivas cliente: %s" % ("RECHAZADO" if not client.configure_round({}, {}, 6) else "ERROR")

func _refresh_papa(prefix: String) -> void:
	_papa_output.text = "%s\nEstado: %s\nPortador: %d\nInmovilización: %.1f s\nAturdimiento: %.1f s" % [
		prefix,
		GameEnums.PapaState.keys()[_papa.papa_state],
		_papa.carrier_id,
		_papa.immobilized_remaining,
		_papa.carrier_stun_remaining,
	]

func _refresh_lives(prefix: String) -> void:
	var state := _lives.get_player_state(1)
	_lives_output.text = "%s\nJugador 1: %d vidas · %s · respawn %.1f s\nDefensores ganan: %s" % [
		prefix,
		int(state.get("lives", 0)),
		"ACTIVO" if state.get("active", false) else "INACTIVO",
		float(state.get("respawn_remaining", 0.0)),
		"SI" if _lives.should_defenders_win() else "NO",
	]

func _refresh_beast(prefix: String) -> void:
	_beast_output.text = "%s\nAparecida: %s · Reloj: %.1f s\nOlla: %s · Cooldowns: %s" % [
		prefix,
		"SI" if _beast.appeared else "NO",
		_beast.round_elapsed,
		"ABIERTA" if _beast.can_enter_pot_room() else "BLOQUEADA",
		str(_beast.cooldowns),
	]

func _refresh_abilities(prefix: String) -> void:
	var snapshot := _abilities.get_snapshot()
	_abilities_output.text = "%s\nTrampas activas: %d\nEnfurecida: %s · Velocidad %.2fx · Cooldown %.2fx" % [
		prefix,
		snapshot.traps.size(),
		"SI" if snapshot.beast_enraged else "NO",
		float(snapshot.beast_speed_multiplier),
		float(snapshot.beast_cooldown_multiplier),
	]

func _role_or_passive_text(assignment: Dictionary) -> String:
	if int(assignment.role) >= 0:
		return "ROL " + GameEnums.DefenderRole.keys()[int(assignment.role)]
	return "PASIVA " + GameEnums.AttackerPassive.keys()[int(assignment.passive)]

func _add_heading(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	parent.add_child(label)

func _button_row(parent: VBoxContainer) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	return row

func _add_button(parent: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)

func _add_output(parent: VBoxContainer) -> Label:
	var output := Label.new()
	output.custom_minimum_size = Vector2(0.0, 110.0)
	output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	output.add_theme_font_size_override("font_size", 15)
	parent.add_child(output)
	return output
