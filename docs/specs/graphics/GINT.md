# GINT — Integración y verificación visual por relevos

- Responsables: Juan Diego Balanta y Edwar Estacio
- Turno: C, después de GJ01, GE01, GV01, GK01 y GM01.
- Estado: IN_PROGRESS; GINT01 recorrido completo bloqueado por errores tras desconexión; GINT02 matriz actualizada; GINT03 handoff registrado. Seguimiento: `docs/handoffs/2026-10-10-0745-Juan-GINT-integration-qa.md`.

## Objetivo

Revisar el resultado de las cinco áreas visuales en el mismo flujo ejecutable, detectar solapamientos y dejar evidencia visual reproducible para el equipo.

## Archivos permitidos

- `scenes/` y `scripts/ui/` únicamente para conectar componentes de presentación aprobados; cada cambio de integración se explica en el handoff.
- `tests/ui/`, `tests/qa/` para preview/matriz visual.
- `docs/specs/graphics/`, `docs/handoffs/`, `AI_TRACE.md`.

No cambiar autoridad, reglas, combate, movimiento, colisiones ni transporte LAN. No integrar automáticamente ramas sin revisar el diff y el handoff de su responsable.

## Tareas atómicas

### GINT01 — Ensamblar y recorrer el flujo
- Estado: BLOCKED — revisión de las cinco áreas y suites automatizadas hecha; el recorrido de seis peers alcanza invalidación/resultado pero falla durante el teardown de clientes desconectados en `papoi_game_session.gd`.
- Aceptación: revisar diff/handoff de cada área; recorrer menú→lobby→juego→resultado; documentar referencias rotas con responsable.

### GINT02 — Matriz visual y resoluciones
- Estado: IN_PROGRESS — precolección de evidencia; el cierre depende de GINT01 y aún faltan 1920×1080 y las integraciones TC01–TC04.
- Aceptación: completar la matriz para los escenarios descritos abajo; revisar 1280×720, 1600×900 y 1920×1080; cada fila tiene PASS/FAIL/BLOCKED y evidencia.

### GINT03 — Cierre y relevo
- Estado: IN_PROGRESS — handoff de checkpoint y entrada incremental creados; cierre final depende de GINT02.
- Aceptación: capturas identifican versión/resolución; handoff distingue pruebas manuales/automatizadas y previews/runtime; AI_TRACE incremental y defects priorizados.

## Secuencia de verificación

1. Abrir el proyecto y recorrer menú → host/unirse → lobby → partida → resultado.
2. Comprobar lobby vacío, seis peers, ready/no-ready, cliente, host, error de conexión y desconexión.
3. En partida revisar seis jugadores, equipos/roles/iconos, mapa, Papa, zonas objetivo, HUD, overlay de visión y feedback de acciones.
4. Mostrar ACTIVE, POT_COOKING, ESCAPE, ROUND_RESULT y MATCH_RESULT. Aclarar en la evidencia cuáles estados son runtime y cuáles pertenecen a un preview.
5. Repetir las comprobaciones de composición en 1280×720, 1600×900 y 1920×1080. Confirmar foco teclado, texto sin recorte y HUD sobre overlay.
6. Ejecutar pruebas automatizadas disponibles para escenas/componentes tocados. Separar resultado de pruebas automatizadas del resultado visual manual.

## Matriz — completar durante el relevo

| Caso | Resultado inicial | Evidencia |
|---|---|---|
| Menú y navegación teclado | PASS | GJ05 `gj05_visual_capture_test.gd`; GJ05 `run_gj05_menu_lan_test.ps1` (host+cliente desde menú); evidencia `docs/handoffs/evidence/gj05/`. |
| Errores/validación de red visibles | PASS | GJ05 captura de validación/rechazo; `run_lobby_slots_test.ps1` confirma rechazo del séptimo peer. |
| Lobby 1/6, 6/6, ready/no-ready, host/cliente | FAIL | `lobby_presentation_test.gd` y `run_lobby_slots_test.ps1` PASS; al iniciar seis peers, el runner de desconexión genera errores multiplayer después de cortar peers. Ver handoff GINT. |
| Personajes/equipos/roles distinguibles | BLOCKED | `GV01_CHARACTERS_TEST`, `GV02_ORIENTATION_TEST`, `GV03_SIX_PLAYERS_TEST`, `GM01_ROLE_ICONS_TEST`, `GM04_ROLE_FEEDBACK_TEST` PASS; TC01 sprite replacement y TC03 roles aún TODO. |
| Mapa, bases, rutas, olla y barrera legibles | BLOCKED | `GK01–GK04`, `K01–K04`, `V03` y capturas 1280×720 PASS; la revalidación TC02 de límites/rutas del Turn C sigue TODO. |
| HUD y feedback de acciones sobre visión | BLOCKED | `GE03–GE06`, `GM02–GM04`, `K04` y `GAME_INTEGRATION_TEST` PASS en sus coberturas; TC04 snapshot/cooldown integrado sigue TODO. |
| Estados de resultado de ronda/partida | PASS | `GAME_INTEGRATION_TEST`, `K04_HUD_RESULTS_TEST`, `GE05_RESULT_HIERARCHY_TEST` PASS; GE06 previews distinguidas como simuladas. |
| Layout 1280×720 | PASS | Capturas de GJ05, GK04, GE06 y GM01; automatización de GJ05/GE06 PASS. |
| Layout 1600×900 | PASS | GJ05 y GE06 generan/verifican previews a 1600×900; son previews, no partida LAN real. |
| Layout 1920×1080 | BLOCKED | No existe evidencia ni ejecución a esta resolución en este checkpoint. |

## Revalidación GINT — 2026-10-10

- Godot 4.7.2 editor import/scan: PASS.
- 22 suites headless de mapa, colisiones, integración de juego, GV01–03, GM01–04 y GE03–05: PASS; listado detallado en `docs/handoffs/2026-10-10-0745-Juan-GINT-integration-qa.md`.
- `run_gj05_menu_lan_test.ps1`: PASS, host y cliente recorren el menú y observan roster=2.
- `lobby_presentation_test.gd`: PASS.
- `run_lobby_slots_test.ps1`: PASS; host + cinco clientes, séptimo rechazado, desconexión y roster actualizado.
- `run_disconnect_match_test.ps1`: FAIL después de confirmar `DISCONNECT_HOST_MATCH_INVALIDATED` y `DISCONNECT_CLIENT_RESULT_RECEIVED`; los clientes que siguen activos llaman `get_unique_id()` y RPC tras perder peer. Errores en `scripts/game/papoi_game_session.gd` líneas 92, 109, 184–187 y 555. No se cambió este archivo; asignación pendiente.
- Dependencias Turn C: TC01, TC02, TC03 y TC04 continúan `TODO` en los specs de sus responsables; TC05 por ello no puede cerrarse.

## Aceptación observable

- [ ] Flujo visual completo ejecutado o cada bloqueo tiene reproducción exacta.
- [ ] La matriz tiene PASS/FAIL/BLOCKED y evidencia por cada fila; no quedan filas sin estado.
- [ ] Capturas identifican versión/commit revisado y resolución, sin datos privados innecesarios.
- [ ] Defectos se anotan con prioridad, pasos y responsable; no se corrigen fuera de alcance sin spec.
- [ ] Se revisan los diffs y se deja handoff de relevo con pruebas automatizadas y manuales separadas.
- [ ] `AI_TRACE.md` recibe una entrada incremental; no hay commit automático.

