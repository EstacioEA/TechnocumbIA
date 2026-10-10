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

## Tareas gráficas — GJ01
- Spec: `docs/specs/Juan_Balanta/graphics-spec.md`; plan: `docs/specs/graphics/README.md`.
- Estado: TODO
- Turno: A con Edwar; integración en Turno C.
- Dependencia: G00 — contrato visual compartido.
- Entrega: menú inicial y presentación del lobby LAN; no cambiar autoridad ni protocolo.
- Aceptación: Host/Unirse/Salir; errores IP/conexión visibles; seis slots y estados reales; host/cliente distinguidos; foco de teclado; capturas en dos resoluciones y handoff.

## GINT — Integración visual por relevos (Juan + Edwar)
- Spec: `docs/specs/graphics/GINT.md`.
- Estado: TODO
- Dependencias: GJ01, GE01, GV01, GK01, GM01.
- Aceptación: recorrer el flujo visual integrado; completar matriz con PASS/FAIL/BLOCKED y capturas en 1280×720, 1600×900 y 1920×1080; separar preview de runtime y registrar handoff.
