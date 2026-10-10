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
## 2026-10-09 — ejecución headless y correcciones para Godot 4
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- EVENT_ID: GameJam
- Tarea: instalar Godot 4 de forma temporal, ejecutar pruebas existentes y corregir errores que impedían cargarlas.
- Rama: `Edwar_Estacio/godot-test-fixes`, basada en `develop` actualizado.
- Archivos: `.gitignore`, `scripts/camera/local_camera.gd`, `scripts/camera/vision_overlay.gd`, `scripts/game/match_state.gd`, `scripts/network/network_manager.gd`, `scripts/roles/role_combat_system.gd`, `scripts/ui/lobby/lobby.gd`, `tests/game/game_state_test.gd`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/handoffs/2026-10-09-2339-godot-headless-tests.md`.
- Resumen: se corrigieron inferencias Variant, validación IP y normalización de números JSON; los tests ahora fallan con exit code distinto de cero ante un fallo. E01 pasó y E02 quedó READY.
- Pruebas: análisis/editor headless, escena lobby, test de estado, test de combate y escena de jugador pasaron con Godot 4.7.2.
- Trazabilidad: se restauraron entradas previas de `AI_TRACE.md` desde `fbc7a49` tras una actualización de `develop` que lo había eliminado; esta entrada se anexó al final.
- Limitaciones: no se ejecutó prueba LAN multiinstancia ni una escena completa de partida integrada. El motor quedó en TEMP, fuera del repositorio.

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

## 2026-10-10 — V01 validación de player base
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Valeria Piza
- Tipo: AI_ASSISTED / TESTING / DOCUMENTATION
- Tarea: cerrar V01 después de disponer de Godot 4.7.2 y validar la escena base.
- Rama: `Valeria_Piza/player-base-validation`, basada en `develop`.
- Archivos: `docs/specs/Valeria_Piza/TASKS.md`, `docs/handoffs/2026-10-10-0007-V01-player-base-validation.md`, `AI_TRACE.md`.
- Resumen: `player_base_test.tscn` cargó en Godot 4.7.2 headless con dos instancias del jugador y sin dependencias de red; V01 pasó a `DONE`.
- Limitaciones: la validación fue headless; la inspección visual queda para V04/V05.
## 2026-10-10 — E02 bloqueada antes de implementar
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tipo: AI_ASSISTED / DOCUMENTATION
- Solicitud: continuar con la siguiente tarea individual asignada.
- Tarea candidata: E02 — Máquina de estados de ronda (E01 DONE y E02 READY según el archivo visto en `develop`).
- Rama: `Edwar_Estacio/round-state-machine`, creada desde `main` después de confirmar `origin/main` como predeterminada y actualizarla con fast-forward.
- Resultado: no se modificó código. En la rama se detectó `?? .godot/` y no existe `docs/specs/Edwar_Estacio/TASKS.md`; el archivo de asignación está en `develop`.
- Limitaciones: no se borró ni ocultó `.godot/`; no se ejecutaron pruebas. `CLI_BRANCH_POLICY.md` indica `main`, mientras `SDD_CONTINUE_PROTOCOL.md` indica `develop`; se requiere resolver la discrepancia y mantener la asignación disponible en la base aprobada.
- Siguiente paso: resolver el estado local y la política de base; continuar E02 en rama limpia con sus specs y asignación disponibles.

## 2026-10-10 — E02 máquina de estados de ronda
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- EVENT_ID: GameJam
- Tipo: AI_ASSISTED / TESTING
- Solicitud: completar E02 y resolver los bloqueos de rama y estado local documentados anteriormente.
- Rama: `Edwar_Estacio/round-state-machine-impl`, nueva desde `develop` actualizado; la rama `Edwar_Estacio/round-state-machine` anterior ya estaba integrada en `develop`.
- Archivos: `scripts/game/game_state.gd`, `tests/game/game_state_test.gd`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/handoffs/2026-10-10-0105-E02-round-state-machine.md`.
- Resumen: se centralizaron las transiciones válidas con autoridad del host y restricciones de progresión; se parametrizó el límite de 7 minutos; se añadieron pruebas de flujo válido, transiciones rechazadas sin mutación, timeout, eliminación durante cocción y desempate 2-2 que completa la quinta ronda sin permitir una sexta.
- Pruebas: escaneo editor headless, test de estado, smoke de escena principal, test de combate y escena de jugador pasaron en Godot 4.7.2; `git diff --check` pasó.
- Limitaciones: no se ejecutó LAN multiinstancia; countdown/cocción siguen como balance pendiente. Sin commit ni push.
- Siguiente paso: revisión de equipo; continuar con E03 — marcador y condiciones de resultado.

## 2026-10-10 — E03 marcador y condiciones de resultado
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- EVENT_ID: GameJam
- Tipo: AI_ASSISTED / TESTING / DOCUMENTATION
- Solicitud: continuar con la siguiente tarea individual asignada y resolver cualquier conflicto de implementación.
- Tarea: E03 — Marcador y condiciones de resultado.
- Rama: `Edwar_Estacio/match-results`, creada desde `develop` actualizado por fast-forward.
- Archivos: `scripts/game/game_state.gd`, `tests/game/game_state_test.gd`, `docs/specs/01-network-lan.md`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/handoffs/2026-10-10-0120-E03-match-results.md`.
- Resumen: se valida que la eliminación ocurra con todas las vidas de atacantes agotadas; escape exige Papa cocinada; resultados duplicados no incrementan dos veces el marcador. Se completó la comunicación de resultados por señales al host. Una desconexión no recuperable invalida la partida sin puntos ni ganador, conforme al contrato LAN actualizado.
- Pruebas: test de estado, análisis de proyecto headless, smoke de escena principal, tests de contratos y combate de roles y escena base de jugador pasaron con Godot 4.7.2; `git diff --check` pasó.
- Limitaciones: no se ejecutó partida LAN con seis instancias ni integración de señales con HUD/red (parte del trabajo de integración). Balance de cuenta regresiva, cocción y vidas iniciales queda parametrizado como pendiente.
- Siguiente paso: E04 integración y smoke test cuando estén completadas sus dependencias J03, M02, K03 y V02.

## 2026-10-10 — K02 zonas de objetivo y olla
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING / DOCUMENTATION
- Tarea: implementar zonas de captura y olla, y validar Papa capturada dentro de la olla con autorización del host.
- Rama: `Krystal_Giraldo/pot-zone`, basada en `develop` actualizado.
- Archivos: `scripts/map/papoi_map.gd`, `scripts/objectives/papoi_pot_zone.gd`, `scripts/objectives/papoi_objective_flow.gd`, `scenes/objectives/papoi_objective_flow.tscn`, `tests/qa/k02_pot_zone_test.gd`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-10-0055-K02-pot-zone.md`.
- Resumen: se añadió `CaptureZone`, un validador separado de zona de olla y una detección host-autorizada que acepta únicamente Papa capturada dentro de la olla, sin iniciar cocción ni modificar victoria.
- Limitaciones: la validación LAN completa no pertenece a K02; `AI_TRACE.md` se mantiene solo local y no se publica remotamente.

## 2026-10-10 — bloqueo K03 por dependencia M02
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: DOCUMENTATION
- Tarea: evaluar la siguiente tarea disponible de Krystal y documentar K03 como bloqueada.
- Rama: `Krystal_Giraldo/k03-blocked`, basada en `develop` actualizado.
- Archivos: `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-10-0125-K03-blocked.md`, `AI_TRACE.md`.
- Resumen: K02 y E02 están DONE, pero K03 depende de M02, que sigue TODO. No se implementó lógica duplicada de captura, cocción o escape.
- Limitaciones: se requiere la entrega/integración de M02 antes de crear la rama de implementación de K03; no se creó commit ni se publicó AI_TRACE.md.

## 2026-10-10 — K03 cocción, rescate y escape
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING / DOCUMENTATION
- Tarea: implementar cocción host-autoritativa, rescate de Bestia, transición a escape y detección de base atacante.
- Rama: `Krystal_Giraldo/cooking-rescue-escape`, basada en `develop` actualizado.
- Archivos: `scripts/objectives/papoi_cooking_escape.gd`, `tests/qa/k03_cooking_escape_test.gd`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-10-0210-K03-cooking-rescue-escape.md`.
- Resumen: se reutilizaron `PapaCaptureState` y `BeastAccessState`; el coordinador exige Papa capturada y host, abre acceso de Bestia durante cocción, cancela por rescate, cambia a escape al completar y emite `escape_reached` solo dentro de la base atacante.
- Limitaciones: `escape_reached` debe conectarse al GameState del host para resolver la ronda; este módulo no adjudica puntos ni victoria. AI_TRACE.md permanece local y no se publica remotamente.

## 2026-10-10 — validación K03
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: TESTING / DEBUGGING
- Tarea: validar la secuencia de cocción, rescate de Bestia y escape de K03.
- Archivos: `scripts/objectives/papoi_cooking_escape.gd`, `tests/qa/k03_cooking_escape_test.gd`, `docs/handoffs/2026-10-10-0210-K03-cooking-rescue-escape.md`.
- Resumen: se corrigió la guarda que impedía rescates antes de la aparición de Bestia. `K03_COOKING_ESCAPE_TEST`, `K01_MAP_TEST` y `K02_POT_ZONE_TEST` pasaron con Godot 4.7.2.
- Limitaciones: la señal `escape_reached` aún debe conectarse al GameState autoritativo para resolver la ronda; no se creó commit ni se publicó AI_TRACE.md.

## 2026-10-10 — K04 HUD y pantallas de resultado
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING / DOCUMENTATION
- Tarea: implementar HUD autoritativo de fase, ronda, temporizadores, marcador, vidas, rol, pasiva, cooldowns, desconexión y resultados.
- Rama: `Krystal_Giraldo/hud-results`, basada en `develop` actualizado.
- Archivos: `scripts/ui/papoi_hud.gd`, `tests/qa/k04_hud_results_test.gd`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-10-0220-K04-hud-results.md`.
- Resumen: el HUD consume snapshots de GameState sin modificar autoridad, distingue tiempo de ronda y fase/cocción, muestra contexto del jugador, resultados derivados del host y errores de desconexión en pantalla.
- Limitaciones: la integración LAN debe alimentar snapshots y desconexiones; K05 queda pendiente de J03, V05 y M05. AI_TRACE.md permanece local y no se publica remotamente.

## 2026-10-10 — V02 input y movimiento

- Rama: `Valeria_Piza/player-movement`, basada en `main` actualizado.
- Resultado: acciones WASD registradas y desplazamiento local validado con
  Godot 4.7.2 headless.
- Prueba: `tests/player/player_movement_test.tscn`.
- Siguiente bloqueo externo: V03 requiere K01 de Krystal Giraldo.

## 2026-10-10 — V04 cámara y visión

- Rama: `Valeria_Piza/player-camera-vision`, basada en `develop` actualizado.
- Resultado: cámara local, overlay de visión al 80% y prioridad del HUD
  validados; las instancias remotas no activan cámara ni overlay.
- Prueba: `tests/qa/v04_camera_vision_test.gd` ejecutada con Godot 4.7.2
  headless.
- Siguiente tarea: V05 — Prueba de instancias.

## 2026-10-10 — V05 prueba de instancias

- Rama: `Valeria_Piza/player-smoke-test`, basada en `develop` actualizado.
- Resultado: dos jugadores instancian correctamente; solo el jugador local
  procesa WASD y el remoto acepta únicamente velocidad aplicada por el host.
- Prueba: `tests/player/player_smoke_test.gd` ejecutada con Godot 4.7.2
  headless.
- Resultado del bloque de tareas Valeria: V01 a V05 completadas.

## 2026-10-10 — Corrección de test de estado en develop
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- EVENT_ID: GameJam
- Tipo: DEBUGGING / TESTING
- Solicitud: ayudar a corregir el error de compilación del test de estado en develop.
- Rama: `Edwar_Estacio/fix-game-state-test`, creada desde `develop` actualizado.
- Archivos: `tests/game/game_state_test.gd`, `docs/handoffs/2026-10-10-0130-fix-game-state-test.md`.
- Resumen: se retiró una comprobación redundante que redeclaraba `first_attack`; las comprobaciones equivalentes con `_check` y la declaración usada por el resto del test se conservan.
- Pruebas: test de estado ejecutado con Godot 4.7.2 headless: PASS, exit code 0; `git diff --check` sin errores.
- Limitaciones: no se ejecutó partida LAN multiinstancia. Godot muestra warnings esperados por transiciones inválidas que el test comprueba que sean rechazadas.
- Siguiente paso: revisión e integración de esta rama en develop; no se creó commit automáticamente.

## 2026-10-10 — M02 captura y transporte de Papa
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Miguel Pabon
- Tarea: implementar captura, inmovilización, sprint, soltar y golpe al portador.
- Rama: `Miguel_Pabon/papa-capture`, basada en `develop`.
- Archivos: `scripts/combat/papa_capture_state.gd`, `tests/combat/test_papa_capture_state.gd`, `docs/specs/Miguel_Pabon/TASKS.md`, `docs/handoffs/2026-10-10-0145-M02-papa-capture.md`.
- Resumen: se agregó una máquina de estado host-authoritativa para el transporte de Papa con inmovilización de 20 segundos, reducción temporal de 2 segundos por sprint del Porta Papas y aturdimiento de 3 segundos al soltar o recibir un golpe.
- Limitaciones: la validación espacial y la conexión con GameState/red quedan para integración; M03 conserva la responsabilidad de vidas y daño.

## 2026-10-10 — M03 impactos, vidas y respawn
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Miguel Pabon
- Tarea: implementar impactos sin Papa, vidas, respawn y eliminación de atacantes.
- Rama: `Miguel_Pabon/combat-lives`, basada en `develop`.
- Archivos: `scripts/combat/combat_lives_state.gd`, `tests/combat/test_combat_lives_state.gd`, `docs/specs/Miguel_Pabon/TASKS.md`, `docs/handoffs/2026-10-10-0155-M03-combat-lives.md`.
- Resumen: se agregó estado host-authoritativo con tres vidas por ronda, respawn único de tres segundos, rechazo de golpes al portador y señal consultable de eliminación total.
- Limitaciones: la transición final de GameState y la posición física de respawn quedan para integración.

## 2026-10-10 — M04 Bestia y acceso a olla
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- EVENT_ID: GameJam
- Tipo: AI_ASSISTED / TESTING / DOCUMENTATION
- Tarea: verificar inicio exclusivo del host con seis jugadores listos y propagación de `lobby_start`.
- Rama: `Juan_Balanta/lobby-ready-start`, basada en J02.
- Archivos: `tests/network/ready_start_test.gd`, `tests/network/run_ready_start_test.ps1`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/specs/Juan_Balanta/individual-spec.md`, `docs/handoffs/2026-10-10-0149-J03-lobby-ready-start.md`.
- Resumen: se añadió una prueba con host + cinco clientes que cubre bloqueo con cinco jugadores, bloqueo mientras falte ready, rechazo del inicio solicitado por clientes, UI restringida a host y recepción de `lobby_start` por los seis peers.
- Pruebas: escaneo de proyecto Godot 4.7.2 PASS; runners J01, J02 y J03 PASS; `git diff --check` PASS en revisión final.
- Limitaciones: procesos locales en loopback, sin prueba de LAN física ni firewall; desconexiones durante partida pendientes de J04. Sin commit ni push.

## 2026-10-10 — J04 arnés de desconexiones multiproceso
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- EVENT_ID: GameJam
- Tipo: AI_ASSISTED / TESTING / DOCUMENTATION
- Tarea: crear un procedimiento reproducible para desconexiones antes y durante partida con host y clientes separados.
- Rama: `Juan_Balanta/lan-test-harness`, basada en `develop` con J03 integrado.
- Archivos: `tests/network/disconnect_match_test.gd`, `tests/network/disconnect_test_actor.gd`, `tests/network/run_disconnect_match_test.ps1`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/specs/Juan_Balanta/individual-spec.md`, `docs/handoffs/2026-10-10-0204-J04-disconnect-harness.md`.
- Resumen: el runner cubre salida de lobby antes del inicio, inicio con seis peers, desconexión durante ACTIVE, invalidación host-authoritative sin puntos/ganador y réplica del snapshot a los cuatro peers que permanecen conectados.
- Pruebas: runner J04 PASS; `game_state_test.gd` PASS; runner J03 PASS; `git diff --check` PASS.
- Limitaciones: loopback; el puente `peer_left` a `GameState` es explícito en el fixture y aún no está conectado en runtime; sin commit ni push.
- PARTICIPANT_ID: Miguel Pabon
- Tarea: implementar aparición, ataques, cooldowns y bloqueo de acceso de Bestia a la olla.
- Rama: `Miguel_Pabon/beast-access`, basada en `develop`.
- Archivos: `scripts/combat/beast_access_state.gd`, `tests/combat/test_beast_access_state.gd`, `docs/specs/Miguel_Pabon/TASKS.md`, `docs/handoffs/2026-10-10-0205-M04-beast-access.md`.
- Resumen: se agregó control host-authoritativo de aparición a 30 segundos, ataque básico/especial con cooldowns y acceso a sala condicionado a cocción.
- Limitaciones: el daño final lo resolverá GameState/M03; el enfurecimiento queda para M05 y la identificación final debe conectarse al rol Bestia explícito.

## 2026-10-10 — M05 trampa, pasivas y enfurecimiento
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Miguel Pabon
- Tarea: implementar trampa MVP, efectos de Tanque/Cazador/Porta Papas y enfurecimiento de Bestia.
- Rama: `Miguel_Pabon/abilities-enrage`, basada en `develop`.
- Archivos: `scripts/abilities/abilities_enrage_state.gd`, `tests/combat/test_abilities_enrage_state.gd`, `docs/specs/Miguel_Pabon/TASKS.md`, `docs/handoffs/2026-10-10-0225-M05-abilities-enrage.md`.
- Resumen: se agregó control host-authoritativo de trampa con cooldown, efectos observables de las tres pasivas y enfurecimiento tras cocción con boost de velocidad y cooldowns reducidos.
- Limitaciones: la señal de cocción y los multiplicadores deben conectarse al host/GameState durante la integración; los valores de balance son temporales.

## 2026-10-10 — validación final M05 y compatibilidad K03
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Miguel Pabon
- Tipo: TESTING / DEBUGGING / DOCUMENTATION
- Tarea: validar M05 y corregir la carga headless de K03.
- Rama: `Miguel_Pabon/abilities-enrage`, basada en `develop`.
- Archivos: `scripts/objectives/papoi_cooking_escape.gd`, `docs/handoffs/2026-10-10-0225-M05-abilities-enrage.md`, `AI_TRACE.md`.
- Resumen: M05 pasó su prueba específica y la regresión de Bestia; K03 pasó después de relajar las referencias tipadas del coordinador a `RefCounted`, manteniendo la autoridad del host.
- Pruebas: `test_abilities_enrage_state.gd`, `test_beast_access_state.gd`, `k03_cooking_escape_test.gd` y `git diff --check` pasaron.
- Limitaciones: la señal de cocción, multiplicadores y reducción de sprint todavía requieren conexión con los coordinadores autoritativos durante la integración.

## 2026-10-10 — E04 integración y smoke test
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tarea: conectar inicio de lobby, estado autoritativo de partida, módulos de combate/cocción/escape y HUD para la partida LAN 3v3.
- Rama: `Edwar_Estacio/game-integration`, basada en `develop`.
- Archivos: `scripts/game/game_state.gd`, `scripts/game/papoi_game_session.gd`, `scripts/network/network_manager.gd`, `scripts/ui/lobby/lobby.gd`, `scenes/game/papoi_game.tscn`, `tests/game/game_integration_test.gd`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/handoffs/2026-10-10-0236-E04-game-integration.md`, `AI_TRACE.md`.
- Resumen: se agregó el coordinador de partida host-autoritativo, transmisión/validación de snapshots y acciones, movimiento LAN, roster de seis jugadores, integración de captura/cocción/rescate/escape y salida de rondas al HUD; el lobby abre la escena de juego. Se corrigió la firma del callback de movimiento y se aplazaron broadcasts durante desconexiones.
- Pruebas: editor scan, `game_integration_test.gd`, `game_state_test.gd`, K01/K02/K03/K04, V03/V04, contratos de roles, combate, vidas, captura Papa, acceso Bestia, M05, arnés ready/start con seis peers y transporte ENet host-cliente pasaron con Godot 4.7.2; `git diff --check` pasó. `run_lobby_slots_test.ps1` registró el rechazo esperado del séptimo jugador, pero falló al comprobar inmediatamente que el proceso hubiera salido.
- Limitaciones: no se probó una sesión interactiva en seis equipos; lobby y transporte se probaron con procesos Godot locales headless. El mapa sigue usando la escena procedural, no el arte de referencia. Sin commit ni push.
## 2026-10-10 — J05 puente runtime LAN/GameState y J06 verificación física
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: integrar el inicio del lobby y las desconexiones con GameState autoritativo; dejar procedimiento verificable para la prueba LAN física pendiente.
- Rama: `Juan_Balanta/runtime-disconnect-bridge`, basada en `origin/develop` actualizado.
- Archivos: `scripts/network/network_game_bridge.gd`, `scripts/network/network_manager.gd`, `scripts/game/game_state.gd`, `scenes/lobby/lobby.tscn`, `tests/network/disconnect_match_test.gd`, `tests/network/run_disconnect_match_test.ps1`, `tests/network/run_lobby_slots_test.ps1`, `docs/specs/01-network-lan.md`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/specs/Juan_Balanta/individual-spec.md`, `docs/handoffs/2026-10-10-0226-J05-runtime-disconnect-bridge.md`, `docs/handoffs/2026-10-10-0226-J06-lan-physical-blocked.md`.
- Resumen: el bridge inicializa GameState desde el lobby, replica snapshots autoritativos y convierte una salida en partida activa en resultado inválido sin ganador ni puntos. Se rechaza entrada tardía. J05 queda DONE; J06 queda BLOCKED hasta probar en un segundo equipo físico.
- Pruebas: Godot 4.7.2 headless/editor PASS; runners J01-J04 PASS; runner de desconexión con bridge real, cinco clientes, entrada tardía y desconexión activa PASS; `tests/game/game_state_test.gd` PASS; `git diff --check` PASS.
- Limitaciones: todas las pruebas de red ejecutadas usan procesos locales; no se ejecutó conexión física por IP ni comprobación de firewall. Handoff J06 contiene el procedimiento, y sus resultados siguen pendientes.
- Siguiente paso: ejecutar el smoke test J06 con dos computadoras Windows en la misma LAN. No se creó commit ni se hizo push.

## 2026-10-10 — K05 matriz QA de integración
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / TESTING / DOCUMENTATION
- Tarea: ejecutar y documentar la matriz P0 de integración LAN 3v3.
- Rama: `Krystal_Giraldo/qa-matrix`, basada en `develop` actualizado.
- Archivos: `tests/qa/p0_lan_3v3_matrix.md`, `docs/specs/Krystal_Giraldo/TASKS.md`, `docs/handoffs/2026-10-10-0235-K05-qa-matrix.md`, `AI_TRACE.md`.
- Resumen: se ejecutaron pruebas headless de mapa, colisiones, spawns, Papa/olla, cocción, rescate, escape, HUD, resultados, estados de combate, transporte LAN y ready/start. La matriz queda con P0-01 a P0-11 PASS y P0-12 BLOCKED.
- Limitaciones: el runner de lobby detecta `SEVENTH_REJECTED`, pero falla porque el proceso rechazado no termina; por dependencia del pre-match, la prueba de desconexión durante partida no puede completarse. No se modificó la red ni el runner fuera del alcance de K05. Esta entrada se mantiene local y no se publica remotamente.

## 2026-10-10 — Planeación gráfica por relevos
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta (solicitante); tareas asignadas a Juan, Edwar, Valeria, Krystal y Miguel.
- Tarea: planificar la capa gráfica completa con entregas observables y relevo entre el turno activo de Juan/Edwar y el siguiente turno de Valeria/Krystal/Miguel.
- Rama: `Juan_Balanta/graphics-roadmap`, basada en `develop` actualizado.
- Archivos: `docs/specs/graphics/README.md`, `docs/specs/graphics/VISUAL_DIRECTION.md`, cinco `graphics-spec.md`, cinco `TASKS.md`, `docs/specs/INDIVIDUAL_SPECS_README.md`, `docs/handoffs/2026-10-10-graphics-plan.md`.
- Resumen: Edwar lidera contrato visual/Theme/HUD/resultados; Juan menú/lobby; Valeria personajes; Krystal mapa; Miguel roles/feedback; Juan y Edwar integran al regresar. Criterios, dependencias, límites de archivos y evidencia visual definidos para cada spec.
- Pruebas: revisión documental, rama y estado Git; no se ejecutaron pruebas del juego porque no hubo cambios de código.
- Limitaciones: no se especificaron horas de sueño/retorno, así que el relevo se activa por disponibilidad. La licencia del arte pendiente se cubre con placeholders propios.
- Siguiente paso: completar y revisar G00; después iniciar GJ01/GE01 y entregar handoff al Turno B.

## 2026-10-10 — Desglose atómico de tareas gráficas
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta (solicitante); tareas distribuidas entre los cinco integrantes.
- Tarea: dividir el plan visual en entregas observables pequeñas y minimizar bloqueos entre turnos.
- Rama: `Juan_Balanta/graphics-atomic-tasks`, basada en `develop` actualizado.
- Archivos: cinco `graphics-spec.md`, cinco `TASKS.md`, `docs/specs/graphics/README.md`, `docs/specs/graphics/GINT.md`, `docs/handoffs/2026-10-10-graphics-atomic-breakdown.md`.
- Resumen: Juan queda con GJ01–GJ05 sin dependencia de Edwar; puede usar el baseline provisional G00. Edwar trabaja en paralelo GE01–GE06; Valeria, Krystal y Miguel reciben tareas separadas para el Turno B; GINT se desglosa en tres pasos.
- Pruebas: revisión documental y `git diff --check`; no se ejecutaron pruebas del juego porque no hubo cambios de código.
- Limitaciones: menú/lobby de Juan usará estilos provisionales hasta que se aplique el Theme refinado en integración.
- Siguiente paso: Juan comienza GJ01; Edwar puede iniciar GE01 en paralelo.

## 2026-10-10 — GJ01 cascarón del menú
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: crear la escena inicial visual de Papoi con acciones Host, Unirse y Salir.
- Rama: `Juan_Balanta/gj01-menu-shell`, basada en `develop` actualizado.
- Archivos: `scenes/menu/main_menu.tscn`, `scripts/ui/menu/main_menu.gd`, `project.godot`, `docs/specs/Juan_Balanta/graphics-spec.md`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/handoffs/2026-10-10-0315-GJ01-main-menu-shell.md`.
- Resumen: se creó una pantalla centrada con paleta provisional G00, foco de teclado inicial, estilos visibles de botones; Host/Unirse emiten señales y muestran que sus paneles se conectarán en tareas siguientes; Salir solicita cerrar.
- Pruebas: `git diff --check` PASS. No se ejecutó Godot ni se capturó la pantalla; por ello GJ01 queda BLOCKED hasta confirmar visualmente carga y foco.
- Limitaciones: conexión y creación de host aún corresponden a GJ02/GJ03; no se necesita a Edwar para continuar.
- Siguiente paso: abrir el proyecto y verificar la escena a 1280×720; luego implementar GJ02.

## 2026-10-10 — GJ02 panel de crear partida
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: construir el panel visual de host y validación de puerto para GJ02.
- Rama: `Juan_Balanta/gj02-host-panel`, basada en `develop` actualizado.
- Archivos: `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd`, `scripts/ui/menu/main_menu.gd`, `docs/specs/Juan_Balanta/graphics-spec.md`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/handoffs/2026-10-10-0322-GJ02-host-panel.md`.
- Resumen: Host abre un panel con puerto por defecto 2456; valida rango 1–65535, muestra errores/confirmación, emite intención de crear y permite volver. El panel no abre ENet; no depende del trabajo de Edwar.
- Pruebas: `git diff --check` PASS. No se ejecutó Godot ni revisión visual, así que GJ02 queda BLOCKED hasta validar en runtime.
- Limitaciones: transporte de servidor se conecta en tarea posterior; GJ01 aún tiene su revisión visual pendiente.
- Siguiente paso: implementar GJ03 (panel join por IP); luego volver a verificar los paneles y el menú.

## 2026-10-10 — GJ03 panel para unirse por IP
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Diego Balanta
- Tarea: crear el panel UI de conexión por IP y enlazarlo al menú.
- Rama: `Juan_Balanta/gj03-join-panel`, basada en `develop`.
- Archivos: `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd`, `scripts/ui/menu/main_menu.gd`, `docs/specs/Juan_Balanta/graphics-spec.md`, `docs/specs/Juan_Balanta/TASKS.md`, `docs/handoffs/2026-10-10-0327-GJ03-join-panel.md`.
- Resumen: panel con campos IP/puerto, validación local IPv4/IPv6 y rango 1–65535, mensajes inline, señal `join_requested(address, port)` y navegación de regreso. No inicia ni modifica transporte de red.
- Pruebas: `git diff --check` PASS. No se ejecutó Godot ni revisión visual/runtime; GJ03 queda BLOCKED hasta revisar la escena.
- Limitaciones: estados reales de conexión, rechazo y desconexión aparecen al integrar la intención con NetworkManager en GJ05; aquí solo se informa que el transporte está pendiente.
- Siguiente paso: implementar GJ04 (preview/presentación independiente del lobby) y después GJ05 (integración y revisión visual).
