# Spec individual — Juan Balanta

## Rol
Networking LAN, host/join por IP y lobby de seis jugadores.

## Objetivo
Permitir que un host cree la partida y que hasta cinco clientes se conecten por IP y puerto dentro de la misma red local.

## Alcance
- Crear servidor ENet de Godot 4.
- Crear cliente mediante IP y puerto introducidos en UI.
- Validar límite máximo de seis peers.
- Mostrar lista de jugadores conectados y estado ready.
- Permitir iniciar únicamente al host cuando haya seis jugadores listos.
- Manejar desconexión antes y durante la partida con mensajes visibles.
- Preparar ejecución local con varias instancias o comandos documentados.

## Archivos permitidos
- `scripts/network/`
- `scenes/lobby/`
- `scripts/ui/lobby/`
- `tests/network/`
- `docs/handoffs/`
- `AI_TRACE.md`

## Contrato mínimo
- Host: crear servidor con puerto configurable.
- Cliente: conectar a `ip:puerto`.
- Eventos: `peer_joined`, `peer_left`, `ready_changed`, `lobby_rejected`, `lobby_start`.
- El cliente envía intención; nunca publica estado de juego autoritativo.

## Requisitos funcionales
1. El host debe rechazar el séptimo jugador.
2. La IP y el puerto deben validarse antes de intentar conectar.
3. Una conexión rechazada debe mostrar una causa legible.
4. Todos los clientes deben recibir la lista actualizada del lobby.
5. Solo el host puede iniciar la partida.
6. El sistema debe limpiar peers desconectados.

## Criterios de aceptación
- [x] Un host puede crear una partida LAN con puerto configurable.
- [x] Un cliente puede conectarse introduciendo la IP del host.
- [x] El lobby muestra correctamente hasta seis jugadores.
- [x] El séptimo intento de conexión es rechazado con mensaje visible.
- [ ] El botón de inicio no está disponible para clientes no host.
- [x] Una desconexión elimina al jugador de la lista y actualiza el estado.
- [x] Existe un comando o procedimiento documentado para ejecutar host y clientes localmente.

Evidencia: criterios de host/cliente/procedimiento en `docs/handoffs/2026-10-10-0124-J01-lan-transport.md`; criterios de seis jugadores, rechazo del séptimo y desconexión en `docs/handoffs/2026-10-10-0137-J02-lobby-slots.md`. Las pruebas usaron procesos separados en loopback; no validan dos equipos físicos ni firewall LAN.

## Entregable de sesión
Crear un handoff con evidencias de conexión, desconexión, límite de jugadores y cualquier limitación de prueba.

## Prompt para la CLI

> Lee `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/CLI_BRANCH_POLICY.md`, `docs/specs/01-network-lan.md`, `docs/specs/04-input-ui.md`, este spec y el handoff más reciente. Antes de modificar cualquier archivo, verifica el estado del repositorio, actualiza `main` y crea una rama nueva exactamente con el formato `Juan_Balanta/Funcionalidad`, usando una funcionalidad concreta en kebab-case, por ejemplo `Juan_Balanta/lan-lobby`. No implementes directamente sobre `main`. Si la rama ya existe, hay cambios locales sin registrar o no puedes verificar la rama activa, detente y documenta el bloqueo. Confirma la rama con `git branch --show-current` antes de editar. Implementa solo el transporte LAN por IP, el lobby y sus estados de conexión para Godot 4. No implementes reglas de combate ni simules matchmaking online. Usa RPCs y señales con payloads mínimos y validados. Prueba host, cliente, rechazo del séptimo peer y desconexión. Revisa el diff, crea un handoff en `docs/handoffs/` con la rama y los commits, y agrega una nueva entrada incremental a `AI_TRACE.md`. No afirmes que una prueba pasó si no fue ejecutada.
