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
- Evidencia: `tests/network/run_disconnect_match_test.ps1` PASS en Godot 4.7.2. Ejecuta primero el lobby de seis slots y desconexión prepartida de J02; luego host + cinco clientes, ready, inicio, desconexión durante ACTIVE, invalidación sin ganador ni puntos y recepción del snapshot en los cuatro clientes conectados. `tests/game/game_state_test.gd` y regresión J03 PASS. Handoff: `docs/handoffs/2026-10-10-0204-J04-disconnect-harness.md`.
- Limitación: la invalidación al recibir `peer_left` se conecta mediante un adaptador del test; el runtime todavía no integra automáticamente `NetworkManager` con `GameState`. Probar en LAN física y completar esa integración son pendientes de integración del juego.

## Tareas gráficas — Turno A de Juan (independiente de Edwar)
- Specs: `docs/specs/Juan_Balanta/graphics-spec.md`, `docs/specs/graphics/README.md`.
- Todas las tareas GJ usan el baseline provisional de `VISUAL_DIRECTION.md`; ninguna espera el Theme ni la aprobación de Edwar.

### GJ01 — Cascarón del menú
- Estado: BLOCKED — implementación creada; falta abrir y verificar visualmente la escena.
- Dependencia: ninguna.
- Archivos: nuevo menú/ script y `project.godot` para establecer escena inicial.
- Aceptación: ejecutar el proyecto abre título, Host, Unirse y Salir; foco teclado visible; Host/Unirse emiten señales UI.

### GJ02 — Crear partida/host
- Estado: BLOCKED — implementación creada; falta revisar el flujo visual.
- Requiere la escena GJ01 existente, no su validación visual; panel aislado mientras tanto.
- Archivos: nuevos `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd` y glue visual en `scripts/ui/menu/main_menu.gd`.
- Aceptación: Host abre panel; puerto inicial 2456; rango 1–65535 validado inline; puerto válido emite señal; Volver regresa al menú; no modificar ENet.

### GJ03 — Unirse por IP
- Estado: BLOCKED — panel implementado; pendiente revisión visual en runtime.
- Dependencia: artefacto GJ01 existente; su revisión visual sigue pendiente.
- Archivos: `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd` y glue de vista en `scripts/ui/menu/main_menu.gd`.
- Aceptación de este corte: IP/puerto editables y validados inline, emitir `join_requested(address, port)`, volver al menú, comunicar que falta integrar transporte. GJ05 conectará la intención con la sesión; esta tarea no cambia la red.

### GJ04 — Lobby
- Estado: DONE — preview aislado comprobado; la navegación desde menú es GJ05.
- Dependencia: GJ02/GJ03 solo para navegación, no para construir/probar escena propia.
- Archivos: `scripts/ui/lobby/lobby.gd`, `tests/ui/lobby_presentation_test.gd`, `tests/network/ready_start_test.gd` (expectativa de cliente actualizada a botón visible deshabilitado), handoff y `AI_TRACE.md`.
- Evidencia: Godot 4.7.2 headless editor PASS; `lobby_presentation_test.gd` PASS; `run_lobby_slots_test.ps1` PASS con seis jugadores, rechazo del séptimo y desconexión. `run_ready_start_test.ps1` comprobó host/cliente e inicio y alcanzó los marcadores PASS, pero el runner termina FAIL por llamadas multiplayer durante cierre de clientes en `papoi_game_session.gd`; se registra para seguimiento, sin cambios a red/autoridad.

### GJ05 — Navegación, tamaños y handoff Turno A
- Estado: TODO; depende de: GJ01–GJ04.
- Aceptación: flujo menú→lobby usable con teclado y mouse; capturas 1280×720 y 1600×900; sin texto cortado; lista de estados cubiertos y pendientes.

## GINT — Integración visual por relevos (Juan + Edwar)
- Spec: `docs/specs/graphics/GINT.md`.
- Estado: TODO; subtareas GINT01–GINT03.
- Dependencias: GJ01–GJ05, GE01–GE06, GV01–GV03, GK01–GK04 y GM01–GM04.
- GINT01 ensambla/recorre; GINT02 completa matriz y resoluciones; GINT03 deja capturas y handoff.
