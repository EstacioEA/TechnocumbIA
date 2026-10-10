# Handoff J05 — Puente runtime de desconexión

- Fecha: 2026-10-10 02:26 (America/Bogota)
- Equipo / participante: TechnocumbIA / Juan Diego Balanta
- Rama: `Juan_Balanta/runtime-disconnect-bridge`
- Base de trabajo: `origin/develop` actualizado; sin commit creado.
- Estado: DONE; pruebas automatizadas locales PASS.

## Implementación

- La escena de lobby instancia `NetworkGameBridge`, que conecta `NetworkManager` con `GameState`.
- Al iniciar el host, valida e inicializa el roster listo y replica snapshots autoritativos versionados a clientes.
- Una desconexión antes de comenzar libera el slot. Una desconexión durante una fase activa invalida la partida una sola vez, sin asignar puntos ni ganador, y comunica el resultado a los clientes restantes.
- Se rechaza un peer que intente entrar después del inicio. Los clientes no publican estados autoritativos.

## Archivos

- `scripts/network/network_game_bridge.gd` (nuevo)
- `scripts/network/network_manager.gd`
- `scripts/game/game_state.gd`
- `scenes/lobby/lobby.tscn`
- `tests/network/disconnect_match_test.gd`
- `tests/network/run_disconnect_match_test.ps1`
- `tests/network/run_lobby_slots_test.ps1`
- `docs/specs/01-network-lan.md`
- `docs/specs/Juan_Balanta/TASKS.md`
- `docs/specs/Juan_Balanta/individual-spec.md`
- `AI_TRACE.md`

## Verificaciones ejecutadas

Con Godot 4.7.2 headless:

- Importación/análisis del proyecto (`--headless --editor --path . --quit`): PASS.
- Transporte J01, lobby/slots J02 y ready/inicio J03: PASS en sus runners multiinstancia.
- J04/J05 (`tests/network/run_disconnect_match_test.ps1`): PASS; roster previo al inicio 6→5, host y cinco clientes listos, inicio y snapshot ACTIVE; cliente tardío rechazado; desconexión durante partida invalida una vez y los cuatro clientes restantes aplican el resultado y muestran el aviso.
- `tests/game/game_state_test.gd`: PASS.
- `git diff --check`: PASS.

## Pendientes y limitaciones

- Las pruebas LAN fueron procesos locales separados; no prueban dos computadoras, interfaces Wi-Fi reales ni reglas de Windows Firewall.
- J06 permanece BLOCKED hasta disponer de un segundo equipo en la misma LAN. Ver `2026-10-10-0226-J06-lan-physical-blocked.md`.
- No se creó commit ni se hizo push.

## Mensaje de commit sugerido

`feat(network): bridge lobby disconnects to authoritative game state`
