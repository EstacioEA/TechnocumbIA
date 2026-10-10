# AI_TRACE

## 2026-10-09 — planificación inicial
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tipo: AI_ASSISTED / DESIGN / DOCUMENTATION
- Solicitud: concretar el diseño de Papoi y organizar un desarrollo SDD paralelo para un evento de 24 horas.
- Decisiones documentadas: 3v3, LAN por IP, Windows, Papa como jugador objetivo, olla, Bestia con aparición retrasada, mejor de 5, roles y pasivas.
- Artefactos generados: `docs/README.md`, `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, specs generales/modulares/atómicos, `docs/PLAN-24H.md` y handoff inicial.
- Pendientes explícitos: balance numérico, transporte exacto de Papa, fecha/hora real de inicio y licencia del arte.

## 2026-10-10 — política de ramas para CLIs
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Edwar Estacio
- Tipo: AI_ASSISTED / DOCUMENTATION
- Solicitud: exigir que cada CLI cree una rama nueva antes de implementar su spec.
- Archivo creado: `docs/CLI_BRANCH_POLICY.md`.
- Convención establecida: `Integrante/Funcionalidad`, usando nombres normalizados como `Edwar_Estacio/game-state`.
- Reglas añadidas: partir desde `main`, no implementar directamente en `main`, detenerse si existen cambios locales o la rama ya existe, y registrar rama, base, commits y pruebas en el handoff.

## 2026-10-09 — bloqueo previo de LAN lobby
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Balanta
- Tarea: implementar el módulo de red LAN y lobby de Papoi.
- Archivos: `docs/handoffs/2026-10-09-1015-lan-lobby-blocked.md`, `AI_TRACE.md`.
- Resumen: no se modificó implementación. El árbol estaba limpio al inicio, pero `Juan_Balanta/lan-lobby` ya existía y estaba activa; la política de ramas exige detenerse. `git fetch origin` tuvo éxito y se verificó `origin/main` en `3fff61ba4f8157f72f3b57ce49a862aa57e5c5b4`.
- Limitaciones: no se cambió a `main`, no se creó rama, no se ejecutó pull ni pruebas, y no se implementó el módulo. Pendiente resolver cómo continuar con la rama preexistente.

## 2026-10-09 — implementación LAN lobby
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Juan Balanta
- Tarea: crear host ENet, conectar clientes por IP y puerto, y gestionar el lobby 3v3.
- Archivos: `scripts/network/network_manager.gd`, `scripts/ui/lobby/lobby.gd`, `scenes/lobby/lobby.tscn`, `docs/handoffs/2026-10-09-2246-lan-lobby.md`, `AI_TRACE.md`.
- Resumen: añadido NetworkManager con roster autoritativo, máximo seis jugadores, rechazo de conexiones adicionales, ready, desconexión y comienzo solo por host cuando los seis están listos; añadida escena UI de lobby con validación y errores visibles.
- Limitaciones: el usuario autorizó continuar en la rama existente `Juan_Balanta/lan-lobby`. No fue posible ejecutar Godot ni pruebas de red porque este checkout no contiene `project.godot` y no hay ejecutable Godot en PATH. Queda conectar la señal `lobby_start` con la escena real de partida.

## 2026-10-09 — corrección de referencia del handoff de bloqueo
- Se renombró el handoff de bloqueo a `docs/handoffs/2026-10-09-2248-lan-lobby-blocked.md` para que el nombre refleje la hora real de registro local. Su contenido se conserva; la referencia anterior permanece como parte del historial incremental.
