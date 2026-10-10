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
- Estado: TODO
- Depende de: J01
- Rama sugerida: `Juan_Balanta/lobby-slots`
- Mantener lista de peers y rechazar el séptimo jugador.
- Aceptación: seis slots visibles; séptimo rechazo legible; peer desconectado se elimina.
- Verificación 2026-10-10: la lógica aparece en `scripts/network/network_manager.gd` y la lista en `scripts/ui/lobby/lobby.gd`, pero no hay prueba ejecutada con seis/siete clientes ni desconexión; queda TODO.

## J03 — Ready e inicio de partida
- Estado: TODO
- Depende de: J02, E01
- Rama sugerida: `Juan_Balanta/lobby-ready-start`
- Implementar ready y botón de inicio exclusivo del host.
- Aceptación: solo inicia con seis listos; cliente no puede iniciar; evento de inicio llega a todos.
- Verificación 2026-10-10: hay lógica de ready e inicio host en `NetworkManager` y control visual en la UI; no se ejecutó escenario con seis peers ni se probó intento desde cliente/replicación del inicio; queda TODO.

## J04 — Pruebas multiinstancia y desconexiones
- Estado: TODO
- Depende de: J03
- Rama sugerida: `Juan_Balanta/lan-test-harness`
- Documentar y ejecutar host + clientes; cubrir desconexiones antes y durante partida.
- Aceptación: procedimiento reproducible; resultados PASS/FAIL/BLOCKED en handoff.
- Verificación 2026-10-10: el runner actual solo cubre host y un cliente de transporte; faltan lobby completo y desconexiones antes/durante partida; queda TODO.
