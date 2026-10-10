# Handoff — checkpoint GINT y revalidación de integración

- Fecha: 2026-10-10 07:45 (America/Bogota)
- Integrante: Juan Diego Balanta
- Rama: `Juan_Balanta/turn-c-remediation-qa`
- Base: `develop` en `ff38375`
- Estado: GINT IN_PROGRESS; TC05 BLOCKED por sus dependencias TC01–TC04. Sin commit.

## Trabajo realizado

- Revisé los specs/handoffs integrados de GJ, GE, GV, GK y GM, y la matriz P0 existente.
- Actualicé la matriz GINT con resultados `PASS`, `FAIL` y `BLOCKED`, distinguiendo componentes/previews de la integración runtime.
- Añadí la revalidación actual a `tests/qa/p0_lan_3v3_matrix.md`; conservé el informe histórico de K05.
- Actualicé el estado de GINT y la condición de bloqueo de TC05 en `docs/specs/Juan_Balanta/TASKS.md`.
- No modifiqué código, escenas ni archivos propiedad de los demás integrantes.

## Pruebas ejecutadas

- Godot 4.7.2 `--headless --editor --path . --quit`: PASS; escaneo e importación terminaron.
- 22 suites headless PASS: `gk01_map_visuals_test`, `gk02_base_spawn_visuals_test`, `gk03_pot_barrier_visuals_test`, `gk04_contrast_evidence_test`, `k01_map_test`, `k02_pot_zone_test`, `k03_cooking_escape_test`, `k04_hud_results_test`, `tc02_clean_map_test`, `v03_player_collision_test`, `v04_camera_vision_test`, `game_integration_test`, `gv01_characters_test`, `gv02_orientation_test`, `gv03_six_players_test`, `gm01_role_icons_test`, `gm02_cooldown_feedback_test`, `gm03_papa_feedback_test`, `gm04_role_feedback_test`, `ge03_phase_timers_test`, `ge04_role_cooldown_hud_test`, `ge05_result_hierarchy_test`.
- `tests/ui/run_gj05_menu_lan_test.ps1`: PASS; host y cliente navegan desde el menú y ven roster=2.
- `tests/ui/lobby_presentation_test.gd`: PASS; slots vacíos/parciales/completos, ready, rol, id y estado sin conexión.
- `tests/network/run_lobby_slots_test.ps1`: PASS; seis jugadores, rechazo del séptimo, desconexión y roster actualizado.
- `tests/network/run_disconnect_match_test.ps1`: FAIL al finalizar. Pre-match PASS; host marca `DISCONNECT_HOST_MATCH_INVALIDATED`; cliente recibe `DISCONNECT_CLIENT_RESULT_RECEIVED`. Luego hay errores repetidos en clientes restantes por `get_unique_id()`/RPC con el peer ya cerrado; backtrace en `scripts/game/papoi_game_session.gd` (`_process`, `_physics_process`, `_on_player_movement_intent`, `_on_peer_left`).

## Matriz y límites

- Menú/LAN/lobby y estados de mapa/HUD tienen cobertura automatizada y capturas previas a 1280×720 y 1600×900. Los handoffs distinguen previews simuladas de pruebas runtime.
- No generé capturas nuevas ni sobrescribí evidencia de otros integrantes.
- No hay evidencia a 1920×1080.
- TC01, TC02, TC03 y TC04 siguen `TODO` en sus respectivos specs, aunque sus tareas anteriores GV/GK/GM/GE están integradas. TC05 exige completar las tareas Turn C antes de cerrar la QA final.
- El fallo postdesconexión requiere corregir el teardown del runtime y repetir la prueba. No tiene responsable asignado en los documentos revisados.

## Archivos tocados

- `docs/specs/graphics/GINT.md`
- `docs/specs/Juan_Balanta/TASKS.md`
- `tests/qa/p0_lan_3v3_matrix.md` (sección de revalidación añadida; no se borra el historial)
- `docs/handoffs/2026-10-10-0745-Juan-GINT-integration-qa.md`
- `AI_TRACE.md`

## Próximos pasos

1. Resolver o asignar el defecto de teardown en `papoi_game_session.gd` y repetir `run_disconnect_match_test.ps1`.
2. Esperar la integración/evidencia TC01–TC04 sin alterar las ramas de sus responsables.
3. Completar evidencia a 1920×1080 y realizar el recorrido runtime de seis jugadores a resultados; entonces reanudar GINT01–02 y TC05.
