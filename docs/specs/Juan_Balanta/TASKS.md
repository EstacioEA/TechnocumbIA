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
- Evidencia: `tests/network/run_disconnect_match_test.ps1` y `docs/handoffs/2026-10-10-0204-J04-disconnect-harness.md`; ejecutados en la rama previa. En J05 el escenario de partida se conecta al puente de runtime para eliminar el adaptador anterior.

## J05 — Integración runtime de red y GameState
- Estado: DONE
- Depende de: J03, J04
- Rama: `Juan_Balanta/runtime-disconnect-bridge`
- Archivos permitidos: `scripts/network/`, `scripts/game/`, `scenes/lobby/`, `tests/network/`, `docs/specs/01-network-lan.md`, `docs/specs/Juan_Balanta/`, `docs/handoffs/`, `AI_TRACE.md`.
- Conectar el inicio de lobby al estado autoritativo y tratar desconexiones no recuperables durante la partida.
- Evidencia: `tests/network/run_disconnect_match_test.ps1` PASS con host + cinco clientes. El lobby configura e inicia `GameState`; salir antes del inicio libera el slot; salir en `ACTIVE` invalida una vez sin ganador ni puntos y los cuatro clientes restantes aplican el snapshot y ven el aviso; un peer tardío es rechazado. Regresiones J01-J04 y `tests/game/game_state_test.gd` PASS. Handoff: `docs/handoffs/2026-10-10-0223-J05-runtime-disconnect-bridge.md`.

## J06 — Verificación LAN entre equipos físicos
- Estado: BLOCKED
- Depende de: J05
- Rama sugerida: `Juan_Balanta/lan-physical-smoke`
- Archivos permitidos: `tests/network/`, `docs/handoffs/`, `docs/specs/Juan_Balanta/TASKS.md`, `AI_TRACE.md`.
- Ejecutar host y cliente en dos equipos dentro de la misma LAN, probar unión por IP local y desconexión antes del inicio.
- Aceptación: procedimiento y resultado PASS/FAIL/BLOCKED con IPs privadas redactadas a nivel de subred, puertos y observación de ambos procesos.
- Bloqueo actual y procedimiento: `docs/handoffs/2026-10-10-0223-J06-lan-physical-blocked.md`; esta sesión solo dispone de un equipo y requiere otro dispositivo en la misma LAN.
