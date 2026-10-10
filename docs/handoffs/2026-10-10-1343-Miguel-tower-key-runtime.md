# Handoff — llave de torre integrada en partida runtime

- Fecha/hora: 2026-10-10 13:43 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `develop`.
- Estado: DONE para integración local.

## Problema

La lógica de `TowerKeyState` y el marcador existían, pero la ronda solo dejaba la
llave oculta al configurar el estado. La llave se generaba únicamente después de
un rescate de Papa, por lo que una partida normal no mostraba el objeto ni
permitía abrir la zona de la torre.

## Corrección

- Cada ronda host-autoritativa coloca la llave en `PapoiMap.TOWER_KEY_SPAWN`.
- `TowerKeyToken` recibe el estado replicado y se muestra en la partida.
- El atacante puede recogerla con `E` dentro de `KEY_INTERACTION_DISTANCE`.
- El portador puede abrir la entrada de la torre desde la zona válida.
- Se conserva la restricción de no recoger la llave mientras se porta a Papa.
- El estado continúa siendo host-autoritativo y se replica en el snapshot.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/objectives/tower_key_state_test.gd` | PASS |
| `tests/game/tower_key_runtime_test.gd` | PASS |
| `tests/game/game_integration_test.gd` | PASS |
| `git diff --check` | PASS |

No se creó commit automático.
