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
state_snapshot(tick, phase, players, papa, pot, scores, timer)
round_result(winner, reason)
match_result(winner)
```

## Requisitos
1. El host valida que no haya más de seis jugadores.
2. Solo el host cambia fase, marcador, vidas, cooldowns y estados de objetivo.
3. Las acciones tienen payload mínimo y tipos verificables.
4. Los clientes muestran error de conexión y desconexión.
5. La ronda se puede ejecutar en dos clientes locales para prueba reducida, pero el objetivo de demo es 3v3.

## Pruebas
- Servidor headless inicia sin errores.
- Se conectan seis clientes locales.
- Un cliente no puede declarar una captura modificando un estado local.
- Desconexión antes de iniciar cancela el lobby o libera el slot.
- Estado de ronda y marcador coinciden en todos los clientes después de cada evento.
