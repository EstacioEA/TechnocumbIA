# Handoff — transición automática de rondas y retorno al lobby

- Fecha/hora: 2026-10-10 14:18 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `develop`.
- Estado: DONE para integración local.

## Comportamiento

- Al resolver una ronda, `GameState` mantiene `ROUND_RESULT` durante cinco
  segundos y publica el tiempo restante.
- El HUD muestra en el centro la cuenta regresiva para la siguiente ronda.
- Al terminar la espera, la siguiente ronda se configura automáticamente y
  entra en `ACTIVE` sin intervención del host.
- Al alcanzar el resultado final, `MATCH_RESULT` mantiene cinco segundos de
  cuenta regresiva.
- `PapoiGameSession` solicita el retorno al lobby y `Lobby` vuelve a hacerse
  visible sin destruir la conexión LAN ni mostrar el menú principal.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/game/game_state_test.gd` | PASS |
| `tests/game/game_integration_test.gd` | PASS |
| Carga del proyecto con `godot --headless --editor --quit` | PASS |
| `git diff --check` | PASS |

El preview gráfico del HUD no se ejecutó en modo headless porque requiere
renderer gráfico. No se creó commit automático.
