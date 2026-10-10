# Handoff — Revalidación GINT/TC05

- Fecha/hora: 2026-10-10 10:41 America/Bogota
- Integrante: Juan Diego Balanta
- Rama: `Juan_Balanta/gint-turn-c-integration`
- Base local verificada: `6d8f472` (`origin/develop` actualizado al inicio de este trabajo).
- Objetivo: revalidar el checkpoint integrado, completar evidencia de HUD a 1920×1080 y registrar los bloqueos vigentes de GINT/TC05.

## Alcance y cambios

- Se añadió `tests/qa/gint_hud_1920_preview_test.gd`, un capturador gráfico del HUD real con cinco fixtures: ACTIVE, POT_COOKING, ESCAPE, ROUND_RESULT y MATCH_RESULT. Las imágenes incluyen la etiqueta `PREVIEW · SIMULADO`; no representan una sesión LAN.
- Se guardaron las cinco capturas en `docs/handoffs/evidence/gint/1920x1080/` y se inspeccionaron visualmente ACTIVE y MATCH_RESULT: los paneles y textos visibles caben en 1920×1080.
- Se actualizó la lectura de dependencias: TC01, TC03 y TC04 están integradas; TC02 conserva pendiente la verificación técnica de colisiones/rutas y captura runtime limpia. TC05 permanece TODO/BLOCKED por ese prerequisito y por los fallos del runner descritos abajo.
- No se modificaron escenas ni lógica compartida. El escaneo de Godot regeneró imports/cachés versionados; como el árbol estaba limpio antes de ejecutarlo, esos artefactos se restauraron. Se conservaron solo los archivos de evidencia y QA propios de esta rama.

## Pruebas ejecutadas en este checkpoint

| Prueba | Resultado observado |
|---|---|
| `tests/game/game_integration_test.gd` | PASS — `GAME_INTEGRATION_TEST: PASS`. |
| `tests/ui/gv03_six_players_test.gd` | PASS — seis jugadores/roles y presentación base. |
| `tests/ui/tc04_role_snapshot_hud_test.gd` | PASS — contrato snapshot/HUD de TC04. No demuestra producción real de cooldowns para todos los roles. |
| `tests/qa/tc02_clean_map_test.tscn` vía `--headless --scene ... --quit-after 60` | PASS — overlays de depuración ocultos por defecto. No prueba límites ni rutas transitables. |
| `tests/qa/v04_camera_vision_test.gd` | PASS — prueba automatizada del overlay de visión. |
| `tests/qa/gk04_contrast_evidence_test.gd` | PASS. |
| `tests/qa/gint_hud_1920_preview_test.gd` (Godot 4.7.2 con renderer gráfico) | PASS — cinco estados × 1920×1080; solo preview simulada. |
| `tests/network/run_ready_start_test.ps1` | FAIL en esta reejecución: host y cinco clientes llegaron a `GAME_SESSION_READY`, pero el runner reportó código de salida vacío para `client1` al cerrar. No se registraron errores Godot/ENet en esa salida. La misma prueba tiene PASS consecutivos en el handoff de Edwar `2026-10-10-1023`; queda una discrepancia de cierre entre ejecuciones. |
| `tests/network/run_disconnect_match_test.ps1` | BLOCKED antes del escenario de partida: la fase de lobby anidada agotó el timeout esperando `seventh-rejected`. El log mostró roster host 6→5, pero el séptimo peer no emitió el marcador esperado. Se reprodujo con puerto predeterminado y alternativo; no se verificó desconexión durante partida en estas ejecuciones. |

No se volvió a invocar `tc02_clean_map_test.gd` con `--script`: esa forma no corresponde al harness de escena. El resultado PASS anterior citado arriba proviene del comando correcto con `--scene`.

## Matriz de estado y defectos

- **Personajes, equipos y roles:** PASS en cobertura automatizada (`GV03`); TC01 integrado. Falta recorrer visualmente el flujo completo de seis peers en runtime.
- **Mapa/límites/pasillos/zonas:** BLOCKED, responsable de siguiente acción: Krystal. TC02 debe aportar prueba de colisiones/rutas y captura runtime limpia; el test clean-map solo demuestra ausencia de overlays por defecto.
- **HUD y visión:** PASS en pruebas unitarias de integración y preview. Limitación: los cooldowns del preview son fixtures; la producción runtime de todos los cooldowns y la composición durante una partida completa no quedan acreditadas por estas pruebas.
- **1920×1080:** PASS para los cinco estados del HUD simulado; BLOCKED para layout en sesión LAN real.
- **Runner de inicio:** prioridad alta de QA, owner propuesto Juan/Edwar; revisar por qué el cliente devuelve código vacío tras confirmar snapshot, sin cambiar autoridad/red fuera de la tarea responsable.
- **Runner de desconexión/sexto-slot:** prioridad alta de QA, owner propuesto Juan; estabilizar el marcador de rechazo del séptimo peer antes de atribuir resultado al escenario de desconexión en partida.

## Pendiente para cerrar TC05

1. Integrar evidencia completa de TC02 sobre límites/rutas/zonas.
2. Repetir los dos runners de red hasta resultado consistente y separar fallos de teardown de fallos de gameplay.
3. Hacer recorrido visual real host + cinco clientes, incluyendo menú, lobby, gameplay y resultado, en 1280×720, 1600×900 y 1920×1080. Las pruebas actuales no sustituyen esa inspección.
4. Completar la matriz PASS/FAIL/BLOCKED y actualizar el handoff final. No se creó commit ni se hizo push.
