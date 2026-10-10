# Tareas atómicas — Krystal Giraldo

## K01 — Mapa y puntos de spawn
- Estado: TODO
- Depende de: ninguno
- Rama sugerida: `Krystal_Giraldo/map-spawns`
- Montar mapa, colisiones, bases, sala de olla, barrera y spawns.
- Aceptación: mapa carga; límites funcionan; spawns identificables; rutas transitables.

## K02 — Zonas de objetivo y olla
- Estado: TODO
- Depende de: K01, E01
- Rama sugerida: `Krystal_Giraldo/pot-zone`
- Crear zonas de captura, olla y detección de Papa autorizada por host.
- Aceptación: solo Papa válida inicia la interacción; estado de zona se comunica sin inventar victoria.

## K03 — Cocción, rescate y escape
- Estado: TODO
- Depende de: K02, M02, E02
- Implementar cocción, cancelación por Bestia, cambio a escape y zona de base atacante.
- Aceptación: cocción completa cambia objetivo; rescate cancela; regreso a base emite evento de resultado.

## K04 — HUD y pantallas de resultado
- Estado: TODO
- Depende de: E02, K03
- Mostrar fase, ronda, timer, marcador, vidas, rol, pasiva y cooldowns.
- Aceptación: datos visibles sin logs; resultado de ronda y partida legibles; estados desconectados tienen mensaje.

## K05 — Matriz QA de integración
- Estado: TODO
- Depende de: J03, V05, M05, K04
- Ejecutar casos P0 de lobby, movimiento, captura, cocción, escape, derrota y desconexión.
- Aceptación: cada caso tiene PASS/FAIL/BLOCKED, evidencia y prioridad; defectos críticos tienen siguiente acción.
