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

## 2026-10-09 — combat-roles
- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Miguel Pabon
- Tarea: implementar roles, pasivas, captura de Papa, combate, vidas, cooldowns, trampas y Bestia.
- Archivos: `scripts/roles/role_combat_system.gd`, `tests/combat/test_role_combat_system.gd`, `docs/handoffs/2026-10-09-2233-combat-roles.md`.
- Resumen: se creó un núcleo GDScript host-authoritativo con captura/liberación, inmovilización, sprint, golpes, respawn, Bestia, cooldowns, trampa MVP y efectos verificables de las tres pasivas.
- Limitaciones: el repositorio aún no contiene escenas/proyecto Godot ni módulo de red; los valores de balance no definidos se marcaron como constantes temporales en el handoff.
