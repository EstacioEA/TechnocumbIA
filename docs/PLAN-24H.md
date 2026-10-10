# Plan de 24 horas y reparto paralelo

## Tiempo disponible
La hora de referencia consultada para UTC-05:00 fue 9 de octubre de 2026 a las 10:02 p. m. Si el evento comenzó a las 7:00 p. m. de ese mismo día, han transcurrido aproximadamente 3 h 02 min y quedan **20 h 58 min** de las 24 horas. El primer checkpoint de 9:00 p. m. ya habría pasado; el siguiente sería 7:00 a. m. y el final 5:00 p. m. Esta cifra debe corregirse si la fecha real de inicio fue distinta.

## Objetivo por checkpoint
### Checkpoint 1 — inmediato / recuperación
- Repositorio inicial, specs y handoffs.
- Proyecto Godot abre y ejecuta.
- Decisiones de producto congeladas.

### Checkpoint 2 — 7:00 a. m. / versión jugable
- Host y cliente LAN.
- Movimiento sincronizado.
- Una ronda simplificada completa: captura, transporte, olla, victoria/derrota.
- HUD básico y mapa con colisiones.

### Checkpoint 3 — 5:00 p. m. / demo estable
- 3v3 probado en LAN.
- Mejor de 5, roles, vidas, cooldowns, Bestia, respawn y visión.
- Correcciones de bugs, UX, balance y build Windows.

## Reparto recomendado
### Edwar — Integración, estado de partida y autoridad
Archivos: `scripts/game/`, `scripts/network/`, integración de escenas.
- Congelar enums y estructura de GameState.
- Host autoritativo, fases, marcador y transición de rondas.
- Integrar ramas y ejecutar smoke tests.

### Juan — Red LAN y lobby
Archivos: `scripts/network/`, `scenes/lobby/`, herramientas de ejecución.
- Host/join por IP y puerto.
- Lista de peers, ready, desconexión y prueba de seis instancias.

### Valeria — Jugador, movimiento y cámara
Archivos: `scripts/player/`, `scenes/player/`, cámara/visión.
- CharacterBody2D, colisiones, input, cámara centrada y overlay.

### Miguel — Roles, combate y habilidades
Archivos: `scripts/roles/`, `scripts/combat/`, trampas y cooldowns.
- Pasivas, Papa, Trolazzo, Bestia, golpes, respawn y enfurecimiento.

### Krystal — Mapa, olla, HUD y QA visual
Archivos: `scenes/map/`, `scenes/ui/`, `tests/`, handoffs de prueba.
- Mapa navegable, zonas, olla, HUD, mensajes y matriz de pruebas.

## Orden de implementación
1. Crear proyecto mínimo y ejecutar ventana.
2. Contrato de GameState y enums.
3. Mapa con colisiones y jugador local.
4. Host/join LAN.
5. Sincronización de movimiento.
6. Captura/soltar Papa.
7. Olla y condición de escape.
8. Golpes, vidas y respawn.
9. Roles y cooldowns.
10. Mejor de 5 y alternancia.
11. HUD, visión, audio/efectos mínimos.
12. Pruebas 3v3, corrección y exportación Windows.

## Estrategia de integración
- Commits pequeños por spec/handoff.
- Una rama por persona y PR o merge explícito.
- No mezclar arte, red y lógica en el mismo commit salvo integración.
- Cada integración debe incluir comando de ejecución y resultado.

## Riesgo principal
El mayor riesgo es intentar online, matchmaking, arte final o todas las habilidades antes de tener una ronda LAN completa. Esas tareas se bloquean hasta que P0 esté estable.
