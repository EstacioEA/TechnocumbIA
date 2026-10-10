# Tareas atómicas — Juan Balanta

## J01 — Transporte LAN host/cliente
- Estado: DONE
- Depende de: ninguno
- Rama sugerida: `Juan_Balanta/lan-transport`
- Archivos permitidos: `scripts/network/`, `tests/network/`
- Crear host ENet y cliente por IP/puerto con señales de conexión.
- Aceptación: host inicia; cliente conecta; errores se muestran; no se modifica estado de partida.
- Evidencia: `tests/network/run_lan_transport_test.ps1` PASS en localhost con Godot 4.7.2; valida errores/rangos de IP y puerto, arranque ENet, evento `peer_joined`, conexión del cliente y roster recibido. Handoff: `docs/handoffs/2026-10-10-0124-J01-lan-transport.md`.

## J02 — Lobby y límite de jugadores
- Estado: DONE
- Depende de: J01
- Rama sugerida: `Juan_Balanta/lobby-slots`
- Mantener lista de peers y rechazar el séptimo jugador.
- Aceptación: seis slots visibles; séptimo rechazo legible; peer desconectado se elimina.
- Evidencia: `tests/network/run_lobby_slots_test.ps1` PASS en Godot 4.7.2; probó seis filas visibles, rechazo legible del séptimo, salida de un cliente y roster reducido a cinco en host y observador. Handoff: `docs/handoffs/2026-10-10-0137-J02-lobby-slots.md`.

## J03 — Ready e inicio de partida
- Estado: DONE
- Depende de: J02, E01
- Rama sugerida: `Juan_Balanta/lobby-ready-start`
- Implementar ready y botón de inicio exclusivo del host.
- Aceptación: solo inicia con seis listos; cliente no puede iniciar; evento de inicio llega a todos.
- Evidencia: `tests/network/run_ready_start_test.ps1` PASS en Godot 4.7.2 con host + cinco clientes. El host bloquea el inicio con cinco jugadores y con jugadores no listos; clientes no pueden iniciar ni ven disponible el botón; los seis marcan ready y cada proceso recibe `lobby_start` con seis jugadores listos. Handoff: `docs/handoffs/2026-10-10-0149-J03-lobby-ready-start.md`.

## J04 — Pruebas multiinstancia y desconexiones
- Estado: DONE
- Depende de: J03
- Rama sugerida: `Juan_Balanta/lan-test-harness`
- Documentar y ejecutar host + clientes; cubrir desconexiones antes y durante partida.
- Aceptación: procedimiento reproducible; resultados PASS/FAIL/BLOCKED en handoff.
- Evidencia histórica (checkpoint J04 del handoff 02:04): `tests/network/run_disconnect_match_test.ps1` PASS en Godot 4.7.2. El runner probó lobby de seis slots, salida prepartida, inicio con seis listos, desconexión durante ACTIVE e invalidación sin ganador ni puntos; los cuatro clientes restantes recibieron el snapshot. `tests/game/game_state_test.gd` y regresión J03 PASS. La reejecución GINT 10:41 quedó BLOCKED antes del escenario de partida, por timeout del lobby.
- Limitación vigente: la desconexión se probó solo en loopback; no hay verificación entre equipos físicos ni firewall LAN. La limitación histórica de integrar `peer_left` con `GameState` quedó resuelta en runtime por `PapoiGameSession._on_peer_left()` (`scripts/game/papoi_game_session.gd`); la reejecución GINT del 10:41 no alcanzó el escenario de desconexión durante partida.

## Tareas gráficas — Turno A de Juan (independiente de Edwar)
- Specs: `docs/specs/Juan_Balanta/graphics-spec.md`, `docs/specs/graphics/README.md`.
- Todas las tareas GJ usan el baseline provisional de `VISUAL_DIRECTION.md`; ninguna espera el Theme ni la aprobación de Edwar.

### GJ01 — Cascarón del menú
- Estado: DONE — verificado en runtime a 1280×720 y 1600×900; foco de teclado y capturas comprobados.
- Dependencia: ninguna.
- Archivos: nuevo menú/ script y `project.godot` para establecer escena inicial.
- Aceptación: ejecutar el proyecto abre título, Host, Unirse y Salir; foco teclado visible; Host/Unirse emiten señales UI.

### GJ02 — Crear partida/host
- Estado: DONE — panel verificado; crea host LAN desde el menú y mantiene inicio deshabilitado con menos de seis jugadores.
- Requiere la escena GJ01 existente, no su validación visual; panel aislado mientras tanto.
- Archivos: nuevos `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd` y glue visual en `scripts/ui/menu/main_menu.gd`.
- Aceptación: Host abre panel; puerto inicial 2456; rango 1–65535 validado inline; puerto válido emite señal; Volver regresa al menú; no modificar ENet.

### GJ03 — Unirse por IP
- Estado: DONE — validación inline y unión de cliente desde el menú verificadas; e2e host/cliente localhost con roster de dos.
- Dependencia: artefacto GJ01 existente y revisado visualmente a 1280×720 y 1600×900; GJ05 verificó la integración del flujo.
- Archivos: `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd` y glue de vista en `scripts/ui/menu/main_menu.gd`.
- Criterios del corte aislado GJ03: IP/puerto editables y validados inline; entrada válida emite `join_requested(address, port)` y Volver regresa al menú. En ese corte se informaba que faltaba integrar transporte; GJ05 integró después la intención con la sesión LAN.

### GJ04 — Lobby
- Estado: DONE — preview aislado comprobado; la navegación desde menú es GJ05.
- Dependencia: GJ02/GJ03 solo para navegación, no para construir/probar escena propia.
- Archivos: `scripts/ui/lobby/lobby.gd`, `tests/ui/lobby_presentation_test.gd`, `tests/network/ready_start_test.gd` (expectativa de cliente actualizada a botón visible deshabilitado), handoff y `AI_TRACE.md`.
- Evidencia de tarea: Godot 4.7.2 headless editor, `lobby_presentation_test.gd` y `run_lobby_slots_test.ps1` PASS. El primer `run_ready_start_test.ps1` alcanzó los marcadores de inicio pero falló durante el teardown; Edwar documentó la corrección y tres PASS en `docs/handoffs/2026-10-10-1023-Edwar-lan-match-runner.md`. La reejecución GINT del 10:41 alcanzó `GAME_SESSION_READY` en seis procesos y falló al comprobar el código vacío de salida de `client1`; ver discrepancia vigente en GINT.

### GJ05 — Navegación, tamaños y handoff Turno A
- Estado: DONE — verificado a 1280×720 y 1600×900; e2e menú-host-cliente aprobado. Handoff: `docs/handoffs/2026-10-10-0358-GJ05-menu-lobby-integration.md`.
- Archivos: scripts UI de menú/lobby, `tests/ui/`, capturas en `docs/handoffs/evidence/`, handoff y `AI_TRACE.md`.
- Aceptación: crear/unirse entra al lobby mediante la red existente; rechazo/error visible; recorrido enfocable por teclado y activable por mouse; capturas verificadas a 1280×720 y 1600×900 sin texto cortado; preview rotulado; handoff lista estados y defectos. No cambia protocolo ni autoridad.
- Evidencia: `tests/ui/gj05_visual_capture_test.gd` PASS (12 capturas, estados de host/join/rechazo y controles, ambas resoluciones); `tests/ui/run_gj05_menu_lan_test.ps1` PASS con host y cliente conectados (roster=2); `tests/ui/lobby_presentation_test.gd` PASS; `tests/network/run_lan_transport_test.ps1` PASS; `tests/network/run_lobby_slots_test.ps1` PASS.

## GINT — Integración visual por relevos (Juan + Edwar)
- Spec: `docs/specs/graphics/GINT.md`.
- Estado: IN_PROGRESS; resultados vigentes y defectos reproducibles en `docs/handoffs/2026-10-10-1041-Juan-GINT-runtime-recheck.md`.
- Dependencias: GJ01–GJ05, GE01–GE06, GV01–GV03, GK01–GK04 y GM01–GM04.
- TC01 (Valeria), TC03 (Miguel) y TC04 (Edwar) están integradas; TC02 (Krystal) sigue pendiente de evidencia de colisiones/rutas.
- GINT01: integración automatizada parcial (`GAME_INTEGRATION_TEST`, GV03, TC04, V04 y GK04 PASS); el runner de inicio tiene tres PASS previos reportados por Edwar y una discrepancia de teardown en la reejecución del 10:41. Falta el recorrido visual runtime completo con seis peers.
- GINT02: preview HUD de cinco estados PASS a 1920×1080; el flujo real LAN a las tres resoluciones sigue pendiente.
- GINT03: handoff y AI_TRACE incrementales actualizados; cierre final depende de TC02, runners repetibles y recorrido integrado.

## TC05 — Integración y QA final de remediaciones
- Estado: TODO / BLOCKED por evidencia técnica pendiente de TC02 y por inconsistencia reproducida en los runners de seis jugadores y desconexión. TC01 (Valeria), TC03 (Miguel) y TC04 (Edwar) están integradas; no se atribuye el bloqueo a esas tareas.
- Checkpoint de GINT integrado en `develop`: `e49aed5` (`test(qa): revalidate GINT integration checkpoint`).
- Revalidación: `docs/handoffs/2026-10-10-1041-Juan-GINT-runtime-recheck.md`.
- Resultado parcial: integración de juego, GV03, contrato TC04, V04, GK04 y preview HUD 1920×1080 PASS. El preview a 1920×1080 es simulado; no equivale a sesión LAN real.
- Bloqueo TC02 (owner: Krystal): falta demostrar límites y corredores mediante prueba de colisiones/rutas y captura de gameplay limpio. `tc02_clean_map_test.tscn` solo pasa el control de overlays de depuración ocultos.
- Discrepancia del runner de inicio (seguimiento: Juan/Edwar): seis procesos llegaron a GAME_SESSION_READY, pero la reejecución 10:41 falló al comprobar el código vacío de client1; Edwar había documentado tres PASS previos. Aún no se ha determinado si es teardown o salida del proceso.
- Revalidación del runner de desconexión (seguimiento: Juan): la fase de lobby expiró esperando seventh-rejected; por eso esa ejecución no probó la desconexión durante partida. J04 conserva su PASS histórico separado.
- Cierre requerido: evidencia de TC02 integrada; runners repetibles; recorrido visual de seis peers y matriz completa a 1280×720, 1600×900 y 1920×1080, separando previews de runtime.
