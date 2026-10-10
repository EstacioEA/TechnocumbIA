# Handoff — TC04 contrato de snapshot para rol, pasiva y cooldown

- Fecha/hora: 2026-10-10 08:26 (America/Bogota).
- Integrante: Edwar Estacio.
- Rama: `Edwar_Estacio/role-state-hud-contract`.
- Rama base: `develop` (`e566f7c`), checkpoint integrado requerido por TC04; `main` aún no contiene la asignación ni los módulos de este relevo.
- Objetivo: verificar y conectar al HUD los datos autoritativos de rol, pasiva y cooldown, sin lógica de gameplay en la interfaz.

## Interfaces revisadas

1. `GameState.get_snapshot()` entrega por jugador el rol y la pasiva asignados por el host.
2. `PapoiGameSession._compose_snapshot()` copia esos datos, conserva el estado de cooldown únicamente desde el modelo de combate del host que lo publica y agrega un diccionario explícito por jugador. Si no hay productor conectado, el diccionario queda vacío.
3. El snapshot de red pasa por `_rpc_receive_match_snapshot()` y `MatchState.from_dictionary()` antes de representarse. El esquema existente conserva campos adicionales dentro de cada jugador; no fue necesario cambiar el contrato de red ni su versión.
4. El HUD selecciona el jugador local y presenta los valores recibidos. Rol/pasiva ausentes o inválidos, jugador local ausente y cooldowns no numéricos/negativos se muestran como `SIN DATOS`.

## Archivos modificados

- `scripts/game/papoi_game_session.gd`
- `scripts/ui/papoi_hud.gd`
- `tests/ui/tc04_role_snapshot_hud_test.gd` (nuevo)
- `docs/specs/Edwar_Estacio/TASKS.md`
- `AI_TRACE.md`
- `docs/handoffs/2026-10-10-0826-TC04-role-snapshot-hud-contract.md` (este archivo)

## Pruebas ejecutadas y resultados

| Verificación | Resultado |
|---|---|
| `tests/ui/tc04_role_snapshot_hud_test.gd` con Godot 4.7.2 headless | PASS — payload host para seis jugadores, preservación al validar/serializar `MatchState`, coherencia de los seis contextos rol/pasiva, cooldown listo/bloqueado/recibido, payload ausente/inválido y jugador local ausente. |
| `tests/ui/ge04_role_cooldown_hud_test.gd` con Godot 4.7.2 headless | PASS — regresión de presentación GE04. |
| `tests/game/game_integration_test.gd` con Godot 4.7.2 headless | PASS — flujo integrado existente. |
| Godot 4.7.2 `--headless --editor --path . --quit` | PASS — importación y escaneo del proyecto. |
| `git diff --check` | PASS — sin errores de whitespace. |

## Decisiones y evidencia visual

- La UI no calcula enfriamientos ni reglas; interpreta el valor numérico recibido y muestra `LISTO` para cero o `BLOQUEADO` con tiempo positivo.
- Para atacante, el sentinel `role = -1` se representa como `ATACANTE` y su pasiva enumera Tanque, Cazador o Porta Papas. Para defensor se muestra Papa, Trolazzo o Bestia y `NINGUNA` como pasiva.
- La prueba usa fixtures determinísticos de los seis tipos para cubrir la variación aleatoria de asignaciones del juego. Son datos de prueba, no una afirmación de una partida real.
- Se revisó el preview rotulado ya existente: `docs/handoffs/GE04-hud-cooldowns-1280x720.png` (`PREVIEW · DATOS SIMULADOS`). GE06 también conserva los previews rotulados de estados. No se creó ni sustituyó captura.
- No se cambió el schema de red ni se modificaron archivos de otros integrantes.

## Riesgos y pendientes

- El snapshot ya tiene un espacio explícito de cooldowns por jugador y serializa el cooldown que publique el modelo host de Bestia. Los productores de habilidades de Porta Papas/Trolazzo y el módulo `RoleCombatSystem` de M05 no están conectados actualmente a `PapoiGameSession`; sus valores reales siguen apareciendo como `sin datos`. No se inventan tiempos.
- No se hizo una LAN de seis equipos ni una captura visual nueva de una sesión runtime; la verificación automatizada local y el preview simulado son evidencias distintas.
- Siguiente paso: Miguel o quien integre M05 conecta los productores autoritativos de habilidad al snapshot; entonces repetir la prueba con cooldowns runtime de esas habilidades y validar en LAN.
