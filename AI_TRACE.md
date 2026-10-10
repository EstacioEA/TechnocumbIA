# AI_TRACE

## 2026-10-09 — planificación inicial
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tipo: AI_ASSISTED / DESIGN / DOCUMENTATION
- Solicitud: concretar el diseño de Papoi y organizar un desarrollo SDD paralelo para un evento de 24 horas.
- Decisiones documentadas: 3v3, LAN por IP, Windows, Papa como jugador objetivo, olla, Bestia con aparición retrasada, mejor de 5, roles y pasivas.
- Artefactos generados: `docs/README.md`, `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, specs generales/modulares/atómicos, `docs/PLAN-24H.md` y handoff inicial.
- Pendientes explícitos: balance numérico, transporte exacto de Papa, fecha/hora real de inicio y licencia del arte.

## 2026-10-10 — política de ramas para CLIs
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tipo: AI_ASSISTED / DOCUMENTATION
- Solicitud: exigir que cada CLI cree una rama nueva antes de implementar su spec.
- Archivo creado: `docs/CLI_BRANCH_POLICY.md`.
- Convención establecida: `Integrante/Funcionalidad`, usando nombres normalizados como `Edwar_Estacio/game-state`.
- Reglas añadidas: partir desde `main`, no implementar directamente en `main`, detenerse si existen cambios locales o la rama ya existe, y registrar rama, base, commits y pruebas en el handoff.

## 2026-10-09 — controlador de jugador, cámara y visión limitada
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Valeria Piza
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING
- Tarea: implementar movimiento reutilizable para Papoi con colisiones, cámara local y visión limitada.
- Rama: `Valeria_Piza/player-camera`, basada en `main` actualizado.
- Archivos: `scripts/player/player_controller.gd`, `scripts/camera/local_camera.gd`, `scripts/camera/vision_overlay.gd`, `scenes/player/player.tscn`, `tests/player/player_test.tscn`, `tests/player/manual_test.md`, `docs/handoffs/2026-10-09-2224-player-camera.md`.
- Resumen: se creó un `CharacterBody2D` configurable con WASD e intención de movimiento, una cámara con límites/suavizado/zoom y un overlay CanvasLayer con aura de visión; las instancias remotas no activan cámara ni overlay local.
- Limitaciones: Godot 4 no está instalado en el entorno, por lo que no se pudo ejecutar la escena ni verificar interactivamente colisiones, cámara o HUD. El repositorio aún no contiene `project.godot`; las acciones WASD se registran en runtime.

## 2026-10-09 — E01 contrato de estado compartido
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- EVENT_ID: GameJam
- Tarea: completar serialización JSON y documentación de enums para el contrato de estado compartido.
- Rama: `Edwar_Estacio/game-state-contract`, basada en `develop` según `docs/SDD_CONTINUE_PROTOCOL.md`.
- Archivos: `scripts/shared/game_enums.gd`, `scripts/game/match_state.gd`, `scripts/game/game_state.gd`, `tests/game/game_state_test.gd`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/handoffs/2026-10-09-2317-E01-game-state-contract.md`.
- Resumen: valores de enums explícitos; `MatchState` serializa y valida JSON con claves de equipo compatibles; se añadió test de round-trip y rechazo de esquema inválido.
- Limitaciones: test no ejecutado (comando Godot terminó con código 127 porque no está instalado); E01 queda `BLOCKED` hasta ejecutar la prueba en Godot 4.

## 2026-10-09 — K01 mapa y puntos de spawn
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING / DOCUMENTATION
- Tarea: completar el mapa base de Papoi con límites, bases, sala de olla, barrera de Bestia, rutas y puntos de spawn identificables.
- Rama: `Krystal_Giraldo/map-spawns`, basada en `develop` actualizado.
- Archivos: `scripts/map/papoi_map.gd`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-09-2328-K01-map-spawns.md`, `AI_TRACE.md`.
- Resumen: se añadieron rutas declaradas, API de límites y rutas, y nodos `Marker2D` nombrados para atacantes, defensores, Papa y Bestia. Se mantuvo separada la lógica de zonas y objetivos de K02/K03.
- Limitaciones: `project.godot` ya existe en la rama integrada, pero no hay ejecutable Godot 4; carga y colisiones quedan BLOCKED para validación runtime. El arte es procedural y no se afirma autorización legal de recursos externos. Esta actualización queda solo en el árbol local y no se publicará remotamente.

## 2026-10-09 — validación runtime K01
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: TESTING / DOCUMENTATION
- Tarea: validar K01 después de configurar Godot 4 global.
- Archivos: `tests/qa/k01_map_test.gd`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-09-2328-K01-map-spawns.md`.
- Resumen: Godot 4.7.2 ejecutó la escena del mapa y la prueba headless `K01_MAP_TEST`, verificando instanciación, spawns, rutas, límite exterior y barrera cerrada. K01 pasó a `DONE`.
- Limitaciones: el escaneo completo del editor aún reporta errores preexistentes en lobby y red, fuera del alcance de K01. Este registro permanece local y no se publicará remotamente.
