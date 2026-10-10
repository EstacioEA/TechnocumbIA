# GINT — Integración y verificación visual por relevos

- Responsables: Juan Diego Balanta y Edwar Estacio
- Turno: C, después de GJ01, GE01, GV01, GK01 y GM01.
- Estado: IN_PROGRESS; TC01/TC03/TC04 integradas; TC02 pendiente de colisiones/rutas. TC05 bloqueada por TC02 y resultados inconsistentes de runners; revalidación: `docs/handoffs/2026-10-10-1041-Juan-GINT-runtime-recheck.md`.

## Objetivo

Revisar el resultado de las cinco áreas visuales en el mismo flujo ejecutable, detectar solapamientos y dejar evidencia visual reproducible para el equipo.

## Archivos permitidos

- `scenes/` y `scripts/ui/` únicamente para conectar componentes de presentación aprobados; cada cambio de integración se explica en el handoff.
- `tests/ui/`, `tests/qa/` para preview/matriz visual.
- `docs/specs/graphics/`, `docs/handoffs/`, `AI_TRACE.md`.

No cambiar autoridad, reglas, combate, movimiento, colisiones ni transporte LAN. No integrar automáticamente ramas sin revisar el diff y el handoff de su responsable.

## Tareas atómicas

### GINT01 — Ensamblar y recorrer el flujo
- Estado: IN_PROGRESS — `GAME_INTEGRATION_TEST`, GV03, TC04 HUD, V04 y GK04 pasan; la reejecución del runner de inicio alcanzó GAME_SESSION_READY en seis procesos y falló al comprobar el código de salida vacío de client1. Falta el recorrido visual runtime completo.
- Aceptación: revisar diff/handoff de cada área; recorrer menú→lobby→juego→resultado; documentar referencias rotas con responsable.

### GINT02 — Matriz visual y resoluciones
- Estado: IN_PROGRESS — preview HUD de cinco estados a 1920×1080 disponible; la matriz runtime sigue bloqueada por TC02 y por recorrido LAN visual pendiente.
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

## Matriz vigente — revalidación 2026-10-10 10:41

| Caso | Estado vigente | Evidencia |
|---|---|---|
| Menú y navegación teclado | PASS | GJ05 `gj05_visual_capture_test.gd`; GJ05 `run_gj05_menu_lan_test.ps1` (host+cliente desde menú); evidencia `docs/handoffs/evidence/gj05/`. |
| Errores/validación de red visibles | PASS en validación UI previa; BLOCKED en reejecución del rechazo del séptimo | GJ05 conserva capturas legibles; el runner anidado agotó el timeout esperando el marcador de rechazo en la revalidación 10:41. |
| Lobby 1/6, 6/6, ready/no-ready, host/cliente | BLOCKED en reejecución actual | Handoffs previos registran PASS; el runner de inicio falló al comprobar el cierre de client1 y el de desconexión expiró antes del escenario de partida. Ver handoff 10:41. |
| Personajes/equipos/roles distinguibles | BLOCKED para recorrido visual integrado; pruebas automatizadas PASS | TC01 integrado; `gv03_six_players_test.gd` PASS. Revisar los seis peers durante el flujo runtime. |
| Mapa, bases, rutas, olla y barrera legibles | BLOCKED | TC02 aún requiere prueba de colisiones/rutas y captura runtime limpia; clean-map PASS solo confirma overlays ocultos. |
| HUD y feedback de acciones sobre visión | BLOCKED para flujo runtime; pruebas de componentes PASS | TC04 snapshot/HUD integrado; `tc04_role_snapshot_hud_test.gd` y V04 PASS. Cooldowns de preview son fixtures, no productores runtime. |
| Estados de resultado de ronda/partida | PASS automatizado/preview; BLOCKED para flujo runtime completo | `GAME_INTEGRATION_TEST`, `K04_HUD_RESULTS_TEST`, `GE05_RESULT_HIERARCHY_TEST` PASS; GE06 distingue previews simuladas. |
| Layout 1280×720 | PASS para menú/previews; BLOCKED para flujo gameplay integrado | GJ05, GK04, GE06 y GM01 tienen evidencia en esta resolución; no equivale al recorrido LAN completo. |
| Layout 1600×900 | PASS para menú/previews; BLOCKED para flujo gameplay integrado | GJ05 y GE06 tienen evidencia en esta resolución; son previews, no partida LAN real. |
| Layout 1920×1080 | PASS preview HUD; BLOCKED runtime | Cinco estados simulados en `evidence/gint/1920x1080/`; no hay captura de partida LAN real. |

## Estado del checkpoint histórico GINT — 2026-10-10 07:45

- Godot 4.7.2 editor import/scan: PASS.
- 22 suites headless de mapa, colisiones, integración de juego, GV01–03, GM01–04 y GE03–05: PASS; listado detallado en `docs/handoffs/2026-10-10-0745-Juan-GINT-integration-qa.md`.
- `run_gj05_menu_lan_test.ps1`: PASS, host y cliente recorren el menú y observan roster=2.
- `lobby_presentation_test.gd`: PASS.
- `run_lobby_slots_test.ps1`: PASS; host + cinco clientes, séptimo rechazado, desconexión y roster actualizado.
- `run_disconnect_match_test.ps1`: PASS tras la correccion de cierre de sesion de `2026-10-10-0800-Juan-disconnect-runtime-fix.md`; el handoff historico del fallo anterior se conserva.
- Estado de dependencias en ese checkpoint: TC01, TC02 y TC04 todavía figuraban TODO; TC03 estaba DONE. Es un registro histórico; el estado vigente está resumido abajo.

## Aceptación observable

- [ ] Flujo visual completo ejecutado o cada bloqueo tiene reproducción exacta.
- [ ] La matriz tiene PASS/FAIL/BLOCKED y evidencia por cada fila; no quedan filas sin estado.
- [ ] Capturas identifican versión/commit revisado y resolución, sin datos privados innecesarios.
- [ ] Defectos se anotan con prioridad, pasos y responsable; no se corrigen fuera de alcance sin spec.
- [ ] Se revisan los diffs y se deja handoff de relevo con pruebas automatizadas y manuales separadas.
- [ ] `AI_TRACE.md` recibe una entrada incremental; no hay commit automático.


## Estado vigente — revalidación 2026-10-10 10:41 (Juan)

Este bloque actualiza el checkpoint vigente; los resultados históricos anteriores se conservan como registro. TC01 sprites está integrado, TC03 está DONE y TC04 snapshot/HUD está integrado con preview. TC02 continúa TODO: su prueba `tc02_clean_map_test.tscn` solo confirma que los overlays de debug están ocultos, no demuestra colisiones ni conectividad de los pasillos. Por ello TC05 aún no puede cerrarse.

| Caso | Resultado vigente | Evidencia/limitación |
|---|---|---|
| Menú, validación de red y lobby | PASS en pruebas anteriores; recorrido visual integrado pendiente | GJ05 handoff y runner; el runner de rechazo del séptimo tuvo timeout en esta reejecución. |
| Seis sprites, equipos y roles | PASS automatizado | `gv03_six_players_test.gd`; TC01 integrado. Recorrido runtime completo pendiente. |
| Límites, corredores y zonas del mapa | BLOCKED | TC02 de Krystal sigue pendiente de prueba de colisiones/rutas y captura limpia en runtime. Clean-map PASS solo valida overlays ocultos por defecto. |
| HUD/snapshot y overlay de visión | PASS en cobertura automatizada | `tc04_role_snapshot_hud_test.gd`, `v04_camera_vision_test.gd`; cooldowns reales de todos los roles y sesión completa no demostrados. |
| Estados ACTIVE, POT_COOKING, ESCAPE, ROUND_RESULT, MATCH_RESULT a 1920×1080 | PASS — preview simulada | `tests/qa/gint_hud_1920_preview_test.gd`, capturas en `docs/handoffs/evidence/gint/1920x1080/`. Inspección visual de ACTIVE y MATCH_RESULT sin recorte visible. |
| Flujo real a 1920×1080 | BLOCKED | No hay captura runtime LAN a esa resolución. |
| Lobby de seis / inicio y snapshot de ronda | FAIL en reejecución del runner | Seis procesos llegaron a `GAME_SESSION_READY`; el cierre falla al consultar código vacío de `client1`. Edwar registra tres PASS previos en su handoff 10:23; investigar discrepancia. |
| Desconexión durante partida | BLOCKED en esta reejecución | La fase de lobby previa agotó el timeout esperando `seventh-rejected`; el escenario de partida no corrió. |

Revalidación y pasos concretos: `docs/handoffs/2026-10-10-1041-Juan-GINT-runtime-recheck.md`.
