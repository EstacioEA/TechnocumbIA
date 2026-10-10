# Tareas atómicas — Krystal Giraldo

## K01 — Mapa y puntos de spawn
- Estado: DONE
- Depende de: ninguno
- Rama sugerida: `Krystal_Giraldo/map-spawns`
- Montar mapa, colisiones, bases, sala de olla, barrera y spawns.
- Aceptación: mapa carga; límites funcionan; spawns identificables; rutas transitables.
- Evidencia: `tests/qa/k01_map_test.gd` pasó con Godot 4.7.2 headless; verificó carga, límites, barrera cerrada, spawns y rutas.

## K02 — Zonas de objetivo y olla
- Estado: DONE
- Depende de: K01, E01
- Rama sugerida: `Krystal_Giraldo/pot-zone`
- Crear zonas de captura, olla y detección de Papa autorizada por host.
- Aceptación: solo Papa válida inicia la interacción; estado de zona se comunica sin inventar victoria.
- Evidencia: `tests/qa/k02_pot_zone_test.gd` pasó con Godot 4.7.2 headless; validó zona de captura, Papa capturada dentro de olla y rechazo de detecciones inválidas/no autorizadas.

## K03 — Cocción, rescate y escape
- Estado: DONE
- Depende de: K02, M02, E02
- Implementar cocción, cancelación por Bestia, cambio a escape y zona de base atacante.
- Aceptación: cocción completa cambia objetivo; rescate cancela; regreso a base emite evento de resultado.
- Evidencia: `tests/qa/k03_cooking_escape_test.gd` pasó con Godot 4.7.2 headless; validó autorización host, cocción, acceso/rescate de Bestia, transición a escape y base atacante.

## K04 — HUD y pantallas de resultado
- Estado: DONE
- Depende de: E02, K03
- Mostrar fase, ronda, timer, marcador, vidas, rol, pasiva y cooldowns.
- Aceptación: datos visibles sin logs; resultado de ronda y partida legibles; estados desconectados tienen mensaje.
- Evidencia: `tests/qa/k04_hud_results_test.gd` pasó con Godot 4.7.2 headless; validó HUD de ronda/cocción, contexto del jugador, resultados y desconexión.

## K05 — Matriz QA de integración
- Estado: DONE
- Depende de: J03, V05, M05, K04
- Ejecutar casos P0 de lobby, movimiento, captura, cocción, escape, derrota y desconexión.
- Aceptación: cada caso tiene PASS/FAIL/BLOCKED, evidencia y prioridad; defectos críticos tienen siguiente acción.
- Evidencia: `tests/qa/p0_lan_3v3_matrix.md` actualizada con 11 casos PASS y P0-12 BLOCKED por defecto reproducible en el runner de lobby/desconexión; handoff `docs/handoffs/2026-10-10-0235-K05-qa-matrix.md`.
