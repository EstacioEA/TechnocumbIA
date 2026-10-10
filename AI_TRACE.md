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
## 2026-10-09 — mapa, olla, escape y HUD
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Tipo: AI_ASSISTED / IMPLEMENTATION / TESTING / DOCUMENTATION
- Tarea: implementar la base de mapa, límites, spawns, zonas de olla y escape, flujo de cocción/rescate y HUD de Papoi sin tocar red, combate ni autoridad del host.
- Archivos: `scenes/map/papoi_map.tscn`, `scripts/map/papoi_map.gd`, `scenes/objectives/papoi_objective_flow.tscn`, `scripts/objectives/papoi_objective_flow.gd`, `scenes/ui/papoi_hud.tscn`, `scripts/ui/papoi_hud.gd`, `tests/qa/p0_lan_3v3_matrix.md`, `docs/handoffs/2026-10-09-2245-map-pot-hud.md`.
- Resumen: se añadieron escenas autocontenidas, colisiones y límites procedurales, puntos de spawn, entrada bloqueable de Bestia, transiciones host-autorizadas ACTIVE/POT_COOKING/ESCAPE/ROUND_RESULT y HUD observador con objetivo visible.
- Limitaciones: no existe `project.godot`, escena de integración, runtime Godot 4 ni arte con licencia confirmada en `main`; las pruebas de runtime y LAN quedan BLOCKED y se registran en la matriz y handoff. No se creó commit.
