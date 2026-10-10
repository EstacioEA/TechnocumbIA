extends SceneTree

const GameEnums = preload("res://scripts/shared/game_enums.gd")
const RoleContracts = preload("res://scripts/roles/role_contracts.gd")
const PapaCapture = preload("res://scripts/combat/papa_capture_state.gd")
const CombatLives = preload("res://scripts/combat/combat_lives_state.gd")
const BeastAccess = preload("res://scripts/combat/beast_access_state.gd")
const AbilitiesEnrage = preload("res://scripts/abilities/abilities_enrage_state.gd")

var _failures: Array[String] = []
var _checks := 0

func _init() -> void:
	call_deferred("run")

func run() -> void:
	_verify_role_contracts()
	_verify_papa_difference()
	_verify_trollazzo_difference()
	_verify_beast_difference()
	_verify_passive_differences()
	_verify_lives_and_host_authority()

	if _failures.is_empty():
		print("ROLE_DIFFERENCES_VERIFICATION: PASS — %d checks" % _checks)
		quit(0)
		return
	for failure in _failures:
		push_error("ROLE_DIFFERENCES_VERIFICATION: %s" % failure)
	quit(1)

func _verify_role_contracts() -> void:
	var host_contracts := RoleContracts.new(true)
	var client_contracts := RoleContracts.new(false)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var assignments := host_contracts.assign_round(
		[1, 2, 3, 4, 5, 6],
		[1, 2, 3],
		[4, 5, 6],
		rng
	)
	_check(not assignments.is_empty(), "host can create six-player role/passive assignments")
	_check(assignments.players.size() == 6, "assignment contains six players")
	_check(not client_contracts.assign_round([1, 2, 3, 4, 5, 6], [1, 2, 3], [4, 5, 6], rng), "client cannot assign roles")
	_check(GameEnums.DefenderRole.PAPA != GameEnums.DefenderRole.TROLAZZO, "Papa and Trolazzo remain distinct role values")
	_check(GameEnums.DefenderRole.TROLAZZO != GameEnums.DefenderRole.BESTIA, "Trolazzo and Bestia remain distinct role values")
	_check(GameEnums.AttackerPassive.TANQUE != GameEnums.AttackerPassive.CAZADOR, "Tanque and Cazador remain distinct passive values")
	_check(GameEnums.AttackerPassive.CAZADOR != GameEnums.AttackerPassive.PORTA_PAPAS, "Cazador and Porta Papas remain distinct passive values")

func _verify_papa_difference() -> void:
	var papa := PapaCapture.new(true)
	var client_papa := PapaCapture.new(false)
	_check(papa.configure_round(10, [1, 2, 3], [1]), "host configures Papa target and attackers")
	_check(not client_papa.configure_round(10, [1, 2, 3], [1]), "client cannot configure Papa state")
	_check(papa.request_capture(1), "attacker captures Papa")
	_check(papa.papa_state == GameEnums.PapaState.CAPTURED, "Papa role exposes captured state")
	_check(papa.is_papa_immobilized(), "captured Papa is immobilized")
	_check(not papa.request_capture(2), "second attacker cannot capture an already carried Papa")
	_check(papa.request_porta_papas_sprint(1), "Porta Papas reduces Papa immobilization")
	_check(papa.immobilized_remaining < PapaCapture.IMMOBILIZATION_SECONDS, "sprint changes only Papa immobilization")

func _verify_trollazzo_difference() -> void:
	var abilities := AbilitiesEnrage.new(true)
	var client_abilities := AbilitiesEnrage.new(false)
	var roles := {
		4: GameEnums.DefenderRole.PAPA,
		5: GameEnums.DefenderRole.TROLAZZO,
		6: GameEnums.DefenderRole.BESTIA,
	}
	_check(abilities.configure_round(roles, {}, 6), "host configures defensive roles")
	_check(not client_abilities.configure_round(roles, {}, 6), "client cannot configure trap authority")
	_check(abilities.request_trollazzo_trap(5, Vector2(100.0, 100.0)), "Trolazzo can deploy the MVP trap")
	_check(not abilities.request_trollazzo_trap(4, Vector2(100.0, 100.0)), "Papa cannot deploy the Trolazzo trap")
	_check(not abilities.request_trollazzo_trap(5, Vector2(120.0, 100.0)), "Trolazzo trap cooldown blocks repeated deployment")
	_check(abilities.get_snapshot().traps.size() == 1, "one trap is recorded with its owner")

func _verify_beast_difference() -> void:
	var beast := BeastAccess.new(true)
	var client_beast := BeastAccess.new(false)
	_check(beast.configure_round([6, 5, 4], [1, 2, 3], [6, 5]), "host configures Bestia-compatible access")
	_check(not client_beast.configure_round([6, 5, 4], [1, 2, 3]), "client cannot configure Bestia access")
	_check(beast.is_beast_compatible(5), "Trolazzo shares Bestia access")
	_check(not beast.request_basic_attack(1), "Bestia cannot attack before appearing")
	_check(not beast.can_enter_pot_room(), "Bestia is blocked from the pot room outside cooking")
	beast.tick(BeastAccess.BEAST_APPEARANCE_SECONDS)
	_check(beast.appeared, "Bestia appears at the configured delay")
	_check(beast.request_basic_attack(1), "appeared Bestia can perform a basic attack")
	_check(not beast.request_basic_attack(2), "basic attack cooldown blocks repeated use")
	beast.tick(BeastAccess.BASIC_ATTACK_COOLDOWN_SECONDS)
	_check(beast.request_basic_attack(2), "basic attack cooldown expires after five seconds")
	_check(beast.request_basic_attack(3, 5), "Trolazzo uses the same attack contract independently")
	_check(not beast.request_basic_attack(3, 5), "Trolazzo has its own cooldown")
	_check(beast.set_pot_cooking(true), "host opens pot access during cooking")
	_check(beast.can_enter_pot_room(), "Bestia can enter the pot room during cooking")

func _verify_passive_differences() -> void:
	var abilities := AbilitiesEnrage.new(true)
	var passives := {
		1: GameEnums.AttackerPassive.TANQUE,
		2: GameEnums.AttackerPassive.CAZADOR,
		3: GameEnums.AttackerPassive.PORTA_PAPAS,
	}
	_check(abilities.configure_round({}, passives, 6), "host configures attacker passives")
	_check(is_equal_approx(abilities.get_trap_damage_multiplier(1), 0.5), "Tanque reduces trap damage")
	_check(is_equal_approx(abilities.get_trap_damage_multiplier(2), 1.0), "Cazador does not receive Tanque trap reduction")
	_check(is_equal_approx(abilities.get_beast_damage_multiplier(2), 1.25), "Cazador increases damage against Bestia")
	_check(is_equal_approx(abilities.get_beast_damage_multiplier(1), 1.0), "Tanque does not receive Cazador damage bonus")
	_check(is_equal_approx(abilities.get_porta_papas_sprint_reduction(3), 2.0), "Porta Papas reduces immobilization by two seconds")
	_check(is_equal_approx(abilities.get_porta_papas_sprint_reduction(1), 0.0), "Tanque has no Porta Papas sprint effect")
	_check(abilities.request_cooking_completed(), "host can trigger Bestia enrage after cooking")
	_check(is_equal_approx(abilities.get_beast_cooldown(10.0), 5.0), "enrage halves Bestia cooldowns")

func _verify_lives_and_host_authority() -> void:
	var lives := CombatLives.new(true)
	var client_lives := CombatLives.new(false)
	_check(lives.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3]), "host initializes attacker lives")
	_check(not client_lives.start_round([1, 2, 3, 4, 5, 6], [1, 2, 3]), "client cannot initialize lives")
	_check(lives.request_hit_without_papa(1, false), "attacker without Papa loses a life")
	_check(lives.get_player_state(1).lives == CombatLives.STARTING_LIVES - 1, "hit removes exactly one life")
	_check(not lives.request_hit_without_papa(2, true), "attacker carrying Papa does not lose a life")
	_check(lives.get_player_state(2).lives == CombatLives.STARTING_LIVES, "carrier keeps all lives after carrier hit path")
	_check(lives.get_player_state(1).respawn_remaining > 0.0, "hit schedules the documented respawn")
	_check(not client_lives.request_hit_without_papa(1, false), "client cannot apply impacts")

func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(label)
