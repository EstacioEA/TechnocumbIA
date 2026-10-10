# Handoff — corrección de mapa tapado por el menú al iniciar F5

- Fecha/hora: 2026-10-10 13:32 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `develop`.
- Estado: DONE para el flujo local de inicio.

## Causa

El lobby ocultaba su propio panel al recibir el inicio de partida, pero el
`MainMenu` raíz continuaba visible. Su `Background` ocupaba todo el viewport y
tapaba el `Node2D` de `PapoiGameSession`; por eso se veían jugadores y el
overlay de visión, pero no el mapa.

## Corrección

- `Lobby` emite `game_started` después de crear `PapoiGameSession`.
- `MainMenu` escucha esa señal y se oculta completamente.
- El fondo del menú deja de cubrir la escena de gameplay.
- La ruta de salida del menú sigue restaurando `MainMenu.visible = true` cuando
  el usuario abandona el lobby.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/game/f5_game_start_visibility_test.gd` | PASS |
| `tests/game/runtime_map_visibility_test.gd` | PASS |
| `tests/game/game_integration_test.gd` | PASS |
| `git diff --check` | PASS |

No se creó commit automático.
