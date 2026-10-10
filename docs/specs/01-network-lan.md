# Spec modular — Red LAN y autoridad

## Propósito
Sincronizar una partida 3v3 de forma determinista usando host autoritativo y clientes conectados por IP.

## Arquitectura
- `NetworkManager`: crear servidor, conectar cliente, listar peers y manejar desconexiones.
- `GameState`: estado autoritativo de lobby, ronda, jugadores, Papa, olla, tiempo y puntuación.
- `PlayerController`: envía intención de movimiento/acción; no publica estado final.
- RPCs confiables para eventos discretos: asignación, captura, golpe, respawn, inicio/fin de ronda.
- Sincronización frecuente para transformaciones y estados visuales mediante snapshots validados por el host.

## Contrato mínimo
```text
join(ip, port) -> accepted | rejected(reason)
player_ready(peer_id, ready)
request_action(action_name, payload)
state_snapshot(tick, phase, players, papa, pot, scores, timer, round_number, round_winner, round_end_reason, match_winner)
round_result(winner, reason)
match_result(winner)
```

`round_result` y `match_result` son emitidos únicamente por el host. `winner` es un `TeamSide` para resultados normales. Para una desconexión no recuperable durante una ronda, el host invalida la partida sin adjudicar puntos: emite `round_result(-1, DISCONNECT)`, registra `round_winner = -1` y `round_end_reason = DISCONNECT` en el snapshot, pasa por `ROUND_RESULT` a `MATCH_RESULT` y emite `match_result(-1)`. `-1` en estos campos significa partida invalidada/sin ganador, no un equipo.

## Requisitos
1. El host valida que no haya más de seis jugadores.
2. Solo el host cambia fase, marcador, vidas, cooldowns y estados de objetivo.
3. Las acciones tienen payload mínimo y tipos verificables.
4. Los clientes muestran error de conexión y desconexión.
5. La ronda se puede ejecutar en dos clientes locales para prueba reducida, pero el objetivo de demo es 3v3.

## Integración de desconexión con el estado de partida
- El lobby conecta `NetworkManager.lobby_start` con el `GameState` autoritativo del host e inicia el estado con el roster de seis jugadores listos.
- Una salida mientras `GameState` está en `COUNTDOWN`, `ACTIVE`, `POT_COOKING` o `ESCAPE` invalida la partida en el host con `RoundEndReason.DISCONNECT`, ganador `-1` y sin modificar el marcador.
- La salida en `LOBBY` solo libera el slot; no produce un resultado de partida.
- El host replica snapshots serializables mediante RPC fiable. Los clientes validan schema y revision antes de aplicar el snapshot; no pueden mutar el estado autoritativo.
- Una desconexión del host se comunica al cliente como desconexión de sesión; el cliente no intenta resolver ni inventar un resultado.

## Pruebas
- Servidor headless inicia sin errores.
- Se conectan seis clientes locales.
- Un cliente no puede declarar una captura modificando un estado local.
- Desconexión antes de iniciar cancela el lobby o libera el slot.
- Estado de ronda y marcador coinciden en todos los clientes después de cada evento.
