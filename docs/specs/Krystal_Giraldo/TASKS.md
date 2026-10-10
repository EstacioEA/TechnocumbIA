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

## Tareas gráficas — GK01–GK04
- Spec: `docs/specs/Krystal_Giraldo/graphics-spec.md`; turno B; no depende del Theme de Edwar.

### GK01 — Suelo y rutas
- Estado: DONE; remapeo oficial validado visualmente en runtime.
- Aceptación: ruta transitable contrasta con suelo/decoración; paredes no parecen camino.
- Evidencia: `tests/qa/gk01_map_visuals_test.gd`, regresión `tests/qa/k01_map_test.gd` y `docs/handoffs/captura vista fix krystal 4.png`.

### GK02 — Bases y spawns
- Estado: DONE; posiciones del remapeo validadas visualmente en runtime.
- Aceptación: bases y spawns visibles mediante forma/icono/etiqueta, sin mover coordenadas lógicas.
- Evidencia: `tests/qa/gk02_base_spawn_visuals_test.gd`, `tests/qa/gk01_map_visuals_test.gd`, `tests/qa/k01_map_test.gd` y `docs/handoffs/captura vista fix krystal 4.png`.

### GK03 — Olla y barrera
- Estado: DONE; implementación reubicada a Torre y estados cerrado/abierto validados en runtime.
- Aceptación: olla y barrera abierta/cerrada legibles; visual no cambia colisión/objetivo.
- Evidencia: `tests/qa/gk03_pot_barrier_visuals_test.gd`, `docs/handoffs/captura vista fix krystal 4.png` y `docs/handoffs/captura pantalla krystal 5 - estado abierto.png`.

### GK04 — Contraste/evidencia
- Estado: TODO; depende de GK01–GK03.
- Aceptación: overlay no esconde rutas/objetivos/HUD; pruebas mapa conservadas; captura y fuentes de assets documentadas.

## K06 — Remapeo oficial del mapa
- Estado: DONE; autorizado explícitamente para alinear lógica, colisiones y presentación con `assets/maps/Mapa Base.jpeg`.
- Decisión funcional: Hall de Auditorios = base atacante/escape; Biblio = base defensora; Summan = zona de captura; Piedritas = corredor central; Torre = sala de la olla y entrada de Bestia.
- Evidencia técnica: `K01_MAP_TEST`, `K02_POT_ZONE_TEST`, `K03_COOKING_ESCAPE_TEST`, `GK01_MAP_VISUALS_TEST`, `GK02_BASE_SPAWN_VISUALS_TEST` y `GK03_POT_BARRIER_VISUALS_TEST` pasan con Godot 4.7.2 headless.
- Evidencia final: capturas runtime a 1280×720 con barrera cerrada y abierta; no se afirma licencia externa del JPEG.
