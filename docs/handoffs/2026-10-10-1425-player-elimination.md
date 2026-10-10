# Handoff — Eliminación visual de jugadores sin vidas

- **Rama:** `Valeria_Piza/player-elimination`
- **Base:** `origin/develop` en `c6ceb95`
- **Alcance:** sincronizar el estado autoritativo de vidas con la presencia
  visual del jugador durante la ronda.

## Implementación

`PapoiGameSession._render_snapshot()` ahora aplica los campos autoritativos
`active` y `lives` a cada actor. Un atacante con `lives == 0` queda eliminado
visualmente, se oculta junto con sus componentes, se detiene su velocidad y se
deshabilita el control local. Un atacante en respawn permanece oculto mientras
`active == false` y reaparece cuando `CombatLivesState` lo reactiva.

La autoridad de combate no se duplicó: `CombatLivesState` continúa descontando
vidas y `GameState.register_attacker_hit()` continúa resolviendo la ronda con
`ATTACKERS_ELIMINATED` cuando todos los atacantes tienen cero vidas. El cambio
solo presenta el snapshot resultante.

## Verificación

| Comando | Resultado |
|---|---|
| `godot --headless --path . --script res://tests/game/player_elimination_test.gd` | PASS |
| `godot --headless --path . --script res://tests/game/game_integration_test.gd` | PASS |
| `godot --headless --path . --script res://tests/combat/test_combat_lives_state.gd` | PASS |

La prueba integrada agota las tres vidas de cada atacante, verifica que cada
actor desaparece y confirma `ROUND_RESULT` con victoria del equipo defensor.
