# Handoff — J04 pruebas multiproceso y desconexiones

- Fecha/hora: 2026-10-10 02:04 (America/Bogota).
- Participante: Juan Diego Balanta.
- Rama activa: `Juan_Balanta/lan-test-harness`.
- Rama base: `develop` en `4c6b36a10da31c31e4cbe170b7c52f82db5a989a`, donde J03 ya estaba integrado. `origin/main` no contiene las specs J01-J04 ni `scripts/game/game_state.gd`, así que no sirve como base funcional para esta continuación.
- Estado: PASS para el alcance del arnés J04. No se creó commit ni se hizo push.

## Procedimiento reproducible

Desde PowerShell en la raíz del repositorio:

```powershell
$godot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'
& .\tests\network\run_disconnect_match_test.ps1 -GodotPath $godot -Port 24570
```

El runner reserva `Port - 1` para el escenario prepartida y ejecuta el test de J02: host + cinco clientes, sexto roster, salida de un cliente y reducción visible del roster a cinco en host/observador. Después abre un host y cinco clientes en procesos Godot separados, marca listos a los seis, inicia la partida, espera a que `GameState` pase a `ACTIVE` y desconecta un cliente. El host procesa `peer_left`, invalida la ronda con razón `DISCONNECT`, sin ganador ni cambio de marcador; los cuatro clientes que continúan conectados reciben y validan el mismo snapshot.

## Archivos

- `tests/network/disconnect_match_test.gd`: escenarios de host/cliente, estado de partida, desconexión y validación del resultado.
- `tests/network/disconnect_test_actor.gd`: RPC fiable de test para distribuir el snapshot de invalidación y confirmar recepción.
- `tests/network/run_disconnect_match_test.ps1`: ejecuta el escenario prepartida J02 y el escenario multiproceso durante partida.
- `docs/specs/Juan_Balanta/TASKS.md`: J04 marcado DONE con evidencia y limitación de integración.
- `docs/specs/Juan_Balanta/individual-spec.md`: evidencia de desconexión agregada.
- `AI_TRACE.md` y este handoff.

## Pruebas ejecutadas

- `run_disconnect_match_test.ps1 -Port 24570`: PASS; caso prepartida y host + cinco clientes durante partida.
- `tests/game/game_state_test.gd` con Godot 4.7.2: PASS (`PASS: game state system`), incluye invalidación de desconexión sin puntos.
- `run_ready_start_test.ps1 -Port 24571`: PASS; regresión de ready, autoridad de host y `lobby_start`.
- `git diff --check`: PASS al revisar el diff final.

## Limitaciones y pendientes

- Pruebas únicamente en loopback; no se validaron equipos físicos, firewall o pérdida de red en LAN.
- El test conecta explícitamente `NetworkManager.peer_left` con `GameState.resolve_round(DISCONNECT)` en el fixture. El código de runtime aún no contiene ese puente automático; la integración de red y estado debe completarse en la integración del juego.
- El cliente que abandona no recibe el resultado posterior; los cuatro peers restantes confirman el snapshot.
- Sin commit ni push.
