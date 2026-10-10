extends SceneTree

const SYSTEM := preload("res://scripts/roles/role_combat_system.gd")

var failures: Array[String] = []

func _init() -> void:
	var system = SYSTEM.new(true)
	var started: bool = system.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6])
	_assert_true(started, "la ronda asigna roles")
	_assert_equal(system.get_player_state(4)["role"], &"Papa", "Papa se asigna")
	_assert_equal(system.get_player_state(1)["passive"], &"Tanque", "Tanque se asigna")
	_assert_equal(system.get_player_state(3)["passive"], &"Porta Papas", "Porta Papas se asigna")

	_assert_true(system.request_capture_papa(3), "captura de Papa")
	_assert_equal(system.papa_immobilized_remaining, 20.0, "inmovilizacion inicial")
	_assert_true(system.request_porta_papas_sprint(3), "sprint reduce inmovilizacion")
	_assert_equal(system.papa_immobilized_remaining, 18.0, "reduccion de sprint")
	_assert_true(system.request_drop_papa(3), "liberacion manual de Papa")
	_assert_equal(system.papa_carrier_id, -1, "soltar Papa libera el transporte")
	system.tick(5.0)
	_assert_true(system.request_capture_papa(3), "recaptura de Papa")
	_assert_true(system.request_hit_attacker(3), "golpe al portador")
	_assert_equal(system.papa_carrier_id, -1, "golpe suelta Papa")
	_assert_equal(system.get_player_state(3)["lives"], 3, "portador no pierde vida")

	_assert_true(system.request_hit_attacker(1), "golpe sin Papa")
	_assert_equal(system.get_player_state(1)["lives"], 2, "golpe resta una vida")
	_assert_equal(system.get_player_state(1)["respawn_remaining"], 3.0, "respawn de tres segundos")
	system.tick(5.0)
	_assert_true(system.get_player_state(1)["active"], "respawn reactiva atacante")

	system.tick(30.0)
	_assert_true(system.beast_appeared, "Bestia aparece a los treinta segundos")
	_assert_false(system.can_beast_enter_pot_room(), "Bestia bloqueada fuera de la olla")
	_assert_true(system.request_capture_papa(3), "captura para iniciar coccion")
	_assert_true(system.begin_pot_cooking(), "inicio de coccion")
	_assert_true(system.can_beast_enter_pot_room(), "Bestia puede entrar durante coccion")
	_assert_true(system.request_beast_basic_attack(1), "ataque basico de Bestia")
	_assert_false(system.request_beast_basic_attack(1), "cooldown de ataque basico")
	system.tick(5.0)
	_assert_true(system.request_beast_basic_attack(1), "cooldown expira")
	_assert_true(system.finish_pot_cooking(), "finaliza coccion")
	_assert_true(system.beast_enraged, "Bestia se enfurece")
	_assert_equal(system.get_player_state(6)["speed_multiplier"], 1.25, "boost de enfurecimiento")
	_assert_true(system.request_beast_special_attack(1), "ataque especial de Bestia")
	_assert_false(system.request_beast_special_attack(1), "cooldown especial")
	_assert_true(system.request_trollazzo_trap(Vector2.ZERO), "trampa MVP")
	_assert_false(system.request_trollazzo_trap(Vector2.ONE), "cooldown de trampa")
	_assert_equal(system.get_trap_damage_multiplier(1), 0.5, "efecto verificable de Tanque")
	_assert_equal(system.get_beast_damage_multiplier(2), 1.25, "efecto verificable de Cazador")

	if failures.is_empty():
		print("PASS: role combat system")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert_true(value: bool, label: String) -> void:
	if not value:
		failures.append("FAIL: " + label)

func _assert_false(value: bool, label: String) -> void:
	_assert_true(not value, label)

func _assert_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("FAIL: %s (actual=%s expected=%s)" % [label, actual, expected])
