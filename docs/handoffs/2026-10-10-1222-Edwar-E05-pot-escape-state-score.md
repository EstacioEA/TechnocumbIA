# Handoff — E05 estado autoritativo de olla y scoring por escape

- Fecha y hora: 2026-10-10 12:22 America/Bogota
- Integrante: Edwar Estacio
- Rama: `Edwar_Estacio/pot-escape-state`
- Base: `main` actualizado con `git pull --ff-only origin main` a `3fff61b`. La rama de trabajo quedó creada directamente sobre `develop` en `fd50357`, cuyo ancestro es ese `main`; `main` no se modificó. Sin commit ni push.
- Objetivo: entregar el contrato de timer/salida y la API host-side de escape con un punto por ronda; habilitar a M06 para integrar el flujo jugable.

## Cambios

- `GameRules.POT_COOKING_DURATION_SECONDS` define una sola constante compartida de 20 s para `GameState` y presentación.
- `MatchState` schema v2 serializa y valida `escape_available`. La especificación de red documenta el campo; los clientes reciben el estado y solo lo presentan.
- `GameState` emite `escape_availability_changed` y solo habilita la salida cuando el reloj autoritativo llega a cero.
- `GameState.register_escape(peer_id)` exige host, fase `ESCAPE`, Papa cocinada y un peer del equipo atacante. El primer registro resuelve la ronda; cruces posteriores no pueden volver a sumar. Las reglas existentes conservan alternancia, tope de cinco rondas y victoria a tres puntos.
- `PapoiHUD` muestra una barra de progreso calculada desde el tiempo del snapshot y muestra el estado de salida replicado.
- Las pruebas cubren round-trip/schema v2, veinte segundos, rechazo por fase/rol, primer y segundo atacante, puntuación única, alternancia, best-of-five, cierre a tres, la barra y regresiones del HUD/resultados.

## Pruebas ejecutadas

| Comando / prueba | Resultado |
|---|---|
| Godot 4.7.2 `--headless --editor --path . --quit` | PASS; editor scan completado. |
| `tests/game/game_state_test.gd` | PASS, exit code 0; aparecen warnings esperados por transiciones y acciones inválidas verificadas por el test. |
| `tests/ui/ge03_phase_timers_test.gd` | PASS, exit code 0; barra, 10% a 18/20 s, ocultación posterior y salida activa. |
| `tests/ui/tc04_role_snapshot_hud_test.gd` | PASS, exit code 0. |
| `tests/ui/ge05_result_hierarchy_test.gd` | PASS, exit code 0. |
| `tests/game/game_integration_test.gd` | PASS, exit code 0; warning existente por casing de import de Bestia. |
| `tests/network/run_ready_start_test.ps1 -GodotPath <Godot 4.7.2 temporal>` | PASS; host + cinco clientes alcanzaron `GAME_SESSION_READY` y recibieron snapshot inicial; warning existente por casing de import de Bestia. |
| `git diff --check` | PASS. |

Se usó el paquete temporal completo de Godot 4.7.2 porque el wrapper de consola en `C:\godot\godot` no encontraba el ejecutable hermano. El runner PowerShell se repitió con `-GodotPath` y pasó. Los cambios automáticos en `.godot` y sidecars `.import` se restauraron después de probar.

## Riesgos y pendientes

- `scripts/objectives/papoi_cooking_escape.gd` conserva hoy su contador independiente de 30 s. M06 debe retirar ese contador y consumir la transición única de `GameState`.
- `PapoiGameSession._finish_escape_if_at_base()` actualmente restringe el cruce al portador; M06 debe validar posición host-side de cualquier atacante y llamar `GameState.register_escape(peer_id)`.
- Por lo anterior, la ruta completa de depósito/cocción/rescate/salida aún no está validada a 20 s en runtime ni manualmente. Este handoff no declara concluido M06/J05.
- Godot reporta un warning preexistente de mayúsculas al abrir el import de `Bestia/bestia_sprites.png`; no se cambió ese asset ajeno al alcance.

## Siguiente paso

Miguel integra el timer único y el cruce de cualquier atacante en M06, y luego Juan ejecuta J05 con host + cinco clientes para verificar que ROUND_RESULT y un único punto se repliquen a todos.
