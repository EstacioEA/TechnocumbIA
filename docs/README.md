# Papoi — Documentación SDD

Este directorio contiene la fuente operativa de verdad para el desarrollo de Papoi durante la GameJam.

## Orden de lectura para cualquier CLI
1. `docs/CLI_CONTEXT.md`
2. `docs/SDD_ORCHESTRATOR.md`
3. `docs/specs/00-game-general.md`
4. El spec modular relacionado con la tarea
5. El handoff más reciente en `docs/handoffs/`
6. El spec atómico asignado al participante

## Reglas de trabajo
- No implementar una tarea sin leer sus criterios de aceptación.
- No cambiar contratos compartidos sin actualizar el spec modular y crear un handoff.
- Toda sesión debe terminar con evidencia: archivos, comandos ejecutados, resultado y pendientes.
- `AI_TRACE.md` es incremental: nunca se reescriben entradas anteriores.
- El MVP prioriza una partida LAN funcional sobre matchmaking online, arte final o contenido adicional.
