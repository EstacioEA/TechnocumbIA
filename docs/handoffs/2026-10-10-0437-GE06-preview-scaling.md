# Handoff — GE06 preview y escalado del HUD

- Fecha/hora: 2026-10-10 04:37 (America/Bogota)
- Integrante: Edwar Estacio
- Rama: `Edwar_Estacio/hud-preview-scaling`
- Objetivo: presentar cinco estados de HUD identificados como previews simuladas en 1280×720 y 1600×900 y revisar que el texto permanezca dentro del viewport.
- Archivos modificados: `tests/ui/ge06_hud_preview_test.gd`, `docs/specs/Edwar_Estacio/graphics-spec.md`, `docs/specs/Edwar_Estacio/TASKS.md`, `AI_TRACE.md`.
- Archivos creados: diez PNG bajo `docs/handoffs/evidence/ge06/{1280x720,1600x900}/` y este handoff.

## Resultado

La prueba genera capturas de `ACTIVE`, `POT_COOKING`, `ESCAPE`, `ROUND_RESULT` y `MATCH_RESULT` en ambas resoluciones. Cada captura lleva el rótulo `PREVIEW · SIMULADO · <estado>`. El test comprueba el tamaño exacto de la imagen, que los labels visibles queden dentro de los límites de pantalla y que los labels sin ajuste de línea tengan ancho suficiente. Las diez capturas se inspeccionaron visualmente; no se observó texto recortado en 1280×720 ni 1600×900.

## Pruebas de preview

| Verificación | Resultado |
|---|---|
| Godot 4.7.2 gráfico `--path . --script res://tests/ui/ge06_hud_preview_test.gd` | PASS — `GE06_HUD_PREVIEW_TEST: PASS — 5 estados × 2 resoluciones`; código de salida 0. |
| Capturas 1280×720 | PASS — cinco estados, archivos guardados en `evidence/ge06/1280x720/`. |
| Capturas 1600×900 | PASS — cinco estados, archivos guardados en `evidence/ge06/1600x900/`. |
| Inspección de las diez capturas | PASS — todas muestran rótulo de preview y texto dentro del viewport. |

## Pruebas runtime/headless

| Verificación | Resultado |
|---|---|
| Godot 4.7.2 editor scan | PASS. |
| `tests/ui/ge03_phase_timers_test.gd` | PASS. |
| `tests/ui/ge04_role_cooldown_hud_test.gd` | PASS. |
| `tests/ui/ge05_result_hierarchy_test.gd` | PASS. |
| `tests/qa/k04_hud_results_test.gd` | PASS. |
| `tests/game/game_integration_test.gd` | PASS. |
| `git diff --check` | PASS — sin errores de whitespace. |

Estos tests cubren presentación con snapshots y el flujo de integración en Godot. Las capturas son previews con datos simulados; no son una sesión LAN ni prueba del estado visual de todos los clientes conectados.

## Decisiones y limitaciones

- Se usa `root.size` en la prueba gráfica para ejercer el layout a las dos resoluciones sin cambiar `project.godot` ni la resolución de runtime.
- La ventana conserva proporción 16:9. No se revisó 1920×1080 ni relaciones de aspecto distintas.
- La prueba no modifica scripts de runtime, GameState, roles, combate ni red.
- No se creó commit ni se hizo push.

## Siguiente paso

GE01–GE06 del turno gráfico de Edwar están completas. El siguiente trabajo es revisar la matriz GINT con las entregas de Juan, Valeria, Krystal y Miguel.
