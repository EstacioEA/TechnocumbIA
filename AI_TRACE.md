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

## 2026-10-09 — configuración inicial Godot
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: crear la configuración inicial del proyecto Godot 4.
- Archivos: `project.godot`, `docs/handoffs/2026-10-09-2326-project-config.md`, `AI_TRACE.md`.
- Resumen: añadí la configuración Papoi con la escena de lobby existente como escena principal, viewport 1280×720, stretch `canvas_items` y renderizador `gl_compatibility`.
- Limitaciones: `git diff --check` pasó. No se pudo abrir el proyecto ni ejecutar pruebas porque Godot no está disponible en PATH. No se creó commit.

## 2026-10-10 — reparación de compatibilidad y validación en Godot 4.7.2
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: habilitar la apertura y ejecución del proyecto Godot, corregir errores de parseo y validar serialización del estado.
- Rama: `Juan_Balanta/godot-compatibility-fixes`.
- Archivos: `.gitignore`, `scripts/game/match_state.gd`, `scripts/network/network_manager.gd`, `scripts/roles/role_combat_system.gd`, `scripts/ui/lobby/lobby.gd`, `tests/game/game_state_test.gd`.
- Resumen: se corrigió la validación de IP para la API de Godot 4, tipos inferidos que impedían parsear scripts y la normalización de números de JSON para conservar validación entera en el esquema. Se añadió una comprobación de fallo al test round-trip. Se mantuvieron las reglas previas de `.gitignore` y se ignoró `.godot/`.
- Verificación: Godot `4.7.2.stable.official.ed1daf0bf`; importación headless, ejecución headless de escena principal, `tests/game/game_state_test.gd` y `tests/combat/test_role_combat_system.gd` completados con código 0. El test de estado registra warnings esperados al probar rechazos inválidos.
- Limitaciones: no se ejecutaron pruebas de red LAN con procesos separados (host, conexión por IP, seis/septimo jugador ni desconexión); los archivos `.uid` creados por Godot quedan como metadatos generados sin seguimiento. Sin commit.
