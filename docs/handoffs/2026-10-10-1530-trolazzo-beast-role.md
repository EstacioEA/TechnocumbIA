# Handoff — Trolazzo comparte las capacidades de Bestia

- **Rama:** `Valeria_Piza/trolazzo-beast-role`
- **Base:** `origin/develop` en `36b87fe`
- **Alcance:** permitir que Trolazzo use el contrato autoritativo de Bestia sin
  cambiar su identidad visual ni eliminar la lógica histórica de trampas.

## Implementación

`BeastAccessState` conserva a Bestia como propietario principal por
compatibilidad, pero registra todos los defensores compatibles y mantiene
cooldowns independientes por jugador. La sesión autoritativa permite que
Trolazzo use `beast_attack`, acceda a la olla durante `POT_COOKING` y rescate a
Papa bajo las mismas validaciones de proximidad, fase y autoridad que Bestia.

Los snapshots siguen exponiendo `beast_basic` y `beast_special` por jugador;
los identificadores internos de cooldown no se filtran al HUD.

## Verificación

| Comando | Resultado |
|---|---|
| `godot --headless --path . --script res://tests/game/beast_attack_runtime_test.gd` | PASS |
| `godot --headless --path . --script res://tests/combat/test_role_differences_verification.gd` | PASS |
| `godot --headless --path . --script res://tests/qa/k03_cooking_escape_test.gd` | PASS |
| `godot --headless --path . --script res://tests/ui/tc04_role_snapshot_hud_test.gd` | PASS |
| `godot --headless --path . --script res://tests/game/game_integration_test.gd` | PASS |
| `godot --headless --path . --script res://tests/game/game_state_test.gd` | PASS |
| `godot --headless --path . --script res://tests/combat/test_role_combat_system.gd` | PASS |
| `git diff --check` | PASS |

La ejecución headless mantiene el warning preexistente del path con
mayúsculas del sprite de Bestia; no forma parte de este cambio.
