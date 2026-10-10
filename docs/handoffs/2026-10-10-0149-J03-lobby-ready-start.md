# Handoff — J03 ready e inicio de partida

- Fecha/hora: 2026-10-10 01:49 (America/Bogota).
- Participante: Juan Diego Balanta.
- Rama activa: `Juan_Balanta/lobby-ready-start`, basada en el trabajo J02 de `Juan_Balanta/lan-transport`.
- Estado: PASS para J03. No se creó commit ni se hizo push.

## Resultado

Se añadió un arnés multi-proceso que inicia un host y cinco clientes en procesos Godot separados. Verifica que el host no puede iniciar con cinco jugadores ni con seis mientras haya jugadores no listos; cada cliente intenta iniciar y es rechazado, con el botón de inicio oculto/deshabilitado. Tras marcar ready a los seis, el host inicia una sola vez y los seis procesos reciben `lobby_start`; los clientes validan roster de seis, estados listos y etiquetas `LISTO` visibles.

## Archivos

- `tests/network/ready_start_test.gd`: escenarios y aserciones por rol.
- `tests/network/run_ready_start_test.ps1`: orquesta host + cinco clientes, espera marcadores y revisa logs.
- `docs/specs/Juan_Balanta/TASKS.md`: J03 marcado DONE con evidencia.
- `docs/specs/Juan_Balanta/individual-spec.md`: criterio de botón de inicio para clientes marcado.
- `AI_TRACE.md` y este handoff.

## Pruebas ejecutadas

- `tests/network/run_ready_start_test.ps1` con Godot 4.7.2: PASS. Confirmó bloqueos host/cliente, ready de seis jugadores y `lobby_start` replicado a todos; los seis procesos finalizaron correctamente.
- Regresión: escaneo headless del proyecto, runner J01 de transporte y runner J02 de slots: PASS.
- `git diff --check`: PASS en la revisión final.

## Pendientes y límites

- Prueba ejecutada en localhost (`127.0.0.1`); no cubre equipos físicos, firewall LAN ni pérdida real de red.
- Desconexiones antes y durante una partida siguen asignadas a J04.
- No se modificó lógica autoritativa del juego ni se creó commit/push.
