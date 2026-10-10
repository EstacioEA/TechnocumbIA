# Matriz P0 — integración LAN 3v3

Rama de ejecución: `Krystal_Giraldo/qa-matrix`

## Preparación reproducible

1. Ejecutar desde la raíz del repositorio con Godot 4.7.2.
2. Para pruebas locales: `Godot_console.exe --headless --path . --script res://tests/qa/<caso>.gd`.
3. Para pruebas LAN: ejecutar los runners de `tests/network/` con `-GodotPath C:\Users\Krystal\AppData\Local\Programs\Godot\Godot_console.exe`.
4. Registrar el resultado real en la columna **Resultado**; no convertir bloqueos de entorno en PASS.
5. La evidencia de esta ejecución corresponde a `2026-10-10`, rama `Krystal_Giraldo/qa-matrix`.

## Casos P0

| ID | Caso | Pasos / resultado esperado | Resultado |
|---|---|---|---|
| P0-01 | Lobby 3v3 | Conectar seis clientes; host inicia con dos equipos de tres y roles visibles. | PASS — `run_ready_start_test.ps1`: seis procesos reciben `lobby_start`; el host acepta el inicio solo con seis jugadores listos. |
| P0-02 | Carga de mapa | Instanciar `PapoiMap`; no hay errores; aparecen límites, bases, rutas, sala y marcadores. | PASS — `K01_MAP_TEST` con Godot 4.7.2 headless. |
| P0-03 | Colisiones y límites | Mover un `CharacterBody2D` contra los cuatro límites y la entrada cerrada; no atraviesa. | PASS — `K01_MAP_TEST` valida límite exterior y barrera de Bestia; `V03_PLAYER_COLLISION_TEST` pasa. |
| P0-04 | Spawns | Consultar `get_spawn_points`; hay tres posiciones por equipo, Papa y Bestia. | PASS — `K01_MAP_TEST` valida tres spawns por equipo y spawns de Papa/Bestia. |
| P0-05 | Papa válida en olla | Host marca Papa válida dentro; el flujo acepta la detección y rechaza una transición no autorizada. | PASS — `K02_POT_ZONE_TEST` valida identidad, captura, posición y autorización del host. |
| P0-06 | Inicio y HUD de cocción | Host inicia; fase `POT_COOKING`, host avanza el reloj mediante `advance_host_clock`, temporizador visible y entrada Bestia desbloqueable por host. | PASS — `K03_COOKING_ESCAPE_TEST` y `K04_HUD_RESULTS_TEST` pasan con Godot 4.7.2 headless. |
| P0-07 | Rescate de Bestia | Durante `POT_COOKING`, host rescata; cocción se cancela y objetivo vuelve a captura. | PASS — `K03_COOKING_ESCAPE_TEST` valida rescate solo durante cocción y cancelación. |
| P0-08 | Escape | Al finalizar cocción, fase `ESCAPE`; solo host puede marcar escape en base atacante. | PASS — `K03_COOKING_ESCAPE_TEST` valida transición, base atacante y guarda host. |
| P0-09 | HUD de partida | Mostrar fase, ronda, tiempo, marcador, vidas, rol, pasiva, cooldowns y objetivo sin logs. | PASS — `K04_HUD_RESULTS_TEST` valida todas las etiquetas y el objetivo visible. |
| P0-10 | Resultado de ronda/partida | Integración muestra paneles de resultado sin inventar condición de victoria. | PASS — `K04_HUD_RESULTS_TEST` valida paneles; `game_state_test.gd` valida resultados autoritativos de ronda/partida. |
| P0-11 | Derrota por tiempo/vidas | Host resuelve según estado compartido; UI muestra el resultado. | PASS — `game_state_test.gd` valida timeout, eliminación de atacantes, marcador y transición a resultado. |
| P0-12 | Desconexión | Desconectar cliente; host cancela o invalida explícitamente, sin continuar silenciosamente. | BLOCKED — `run_disconnect_match_test.ps1` no supera el pre-match porque `run_lobby_slots_test.ps1` detecta el rechazo del séptimo cliente pero falla al esperar su cierre; la validación activa de invalidación no puede completarse. |

## Defectos y prioridades

- **P0 bloqueante:** corregir el cierre del proceso rechazado en `tests/network/lobby_slots_test.gd` o su runner; mientras tanto P0-12 no tiene evidencia multiinstancia completa.
- **P0 de integración:** conectar en el host `set_papa_in_pot`, `start_cooking`, `rescue_by_beast`, `apply_cooking_result` y `mark_escape_reached`.
- **P1:** la dirección exacta del arte oficial del mapa y su licencia no están confirmadas; no se afirma autorización legal.
