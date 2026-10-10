# Tareas atómicas — Edwar Estacio

Estados iniciales: `TODO`. La CLI puede seleccionar automáticamente la primera tarea `READY` según `docs/SDD_CONTINUE_PROTOCOL.md`.

## E01 — Contrato de estado compartido
- Estado: DONE — test JSON ejecutado con Godot 4.7.2; round-trip y rechazo de schema inválido pasaron.
- Depende de: ninguno
- Rama sugerida: `Edwar_Estacio/game-state-contract`
- Archivos permitidos: `scripts/shared/`, `scripts/game/`, `tests/game/`
- Construir enums y estructura serializable: fase, equipos, roles, pasivas, estado de Papa, resultado.
- Aceptación: un test serializa/deserializa el estado; nombres y valores están documentados; no depende de nodos visuales.

## E02 — Máquina de estados de ronda
- Estado: DONE — transiciones válidas e inválidas cubiertas por Godot 4.7.2; rechazo sin mutación y límite de 420 segundos verificados.
- Depende de: E01
- Rama sugerida: `Edwar_Estacio/round-state-machine`
- Archivos permitidos: `scripts/game/`, `tests/game/`
- Construir transiciones válidas e inválidas desde lobby hasta resultado.
- Aceptación: cada transición válida tiene test; transición inválida no cambia estado; temporizador máximo de 7 minutos está parametrizado.

## E03 — Marcador y condiciones de resultado
- Estado: DONE — marcador, alternancia, resultados por escape/tiempo/eliminación, invalidación por desconexión y señales del host verificados con Godot 4.7.2.
- Depende de: E02
- Rama sugerida: `Edwar_Estacio/match-results`
- Implementar puntos, alternancia de lados, victoria por escape, derrota por tiempo/eliminación y final al llegar a 3.
- Aceptación: el marcador incrementa una sola vez; no hay sexta ronda; todas las razones producen resultado visible para el host.

## E04 — Integración y smoke test
- Estado: DONE — la prueba headless de integración verificó roster de 6 jugadores, captura, cocción, escape, resultado y rescate; editor scan Godot 4.7.2 y `git diff --check` pasaron.
- Depende de: E03, J03, M02, K03, V02
- Rama sugerida: `Edwar_Estacio/game-integration`
- Integrar contratos sin asumir estados locales y ejecutar smoke test de una ronda.
- Aceptación: el flujo completo arranca, llega a resultado o registra bloqueo reproducible; no rompe módulos existentes.

## Tareas gráficas — Turno A de Edwar
- Spec: `docs/specs/Edwar_Estacio/graphics-spec.md`; plan: `docs/specs/graphics/README.md`.
- Edwar trabaja Theme/HUD/resultados; no modifica menú/lobby de Juan.

### GE01 — Theme compartido
- Estado: DONE — Theme y preview cargan en Godot 4.7.2 headless; verificación visual manual pendiente para QA global.
- Dependencia: ninguna.
- Aceptación: Theme con estados normal/hover/pressed/disabled, foco y colores provisionales; preview observable.

### GE02 — Jerarquía del HUD
- Estado: DONE — K04 PASS y capturas revisadas a 1280×720; overlay de resultado conserva el HUD visible.
- Depende de: GE01.
- Archivos: `scenes/ui/papoi_hud.tscn`, `scripts/ui/papoi_hud.gd` solo presentación, `scenes/ui/papoi_hud_preview.tscn`, `scripts/ui/papoi_hud_preview.gd` y captura de handoff.
- Aceptación: fase/objetivo, tiempos, marcador, vidas y contexto agrupados; HUD sobre overlay; captura 1280×720.

### GE03 — Fases y temporizadores
- Estado: DONE — estados ACTIVE/POT_COOKING/ESCAPE rotulados con texto e icono; timer de cocción identificado por separado; pruebas GE03/K04 PASS; capturas a 1280×720.
- Depende de: GE02.
- Aceptación: ACTIVE/POT_COOKING/ESCAPE distinguibles; timers no se confunden; runtime toma datos existentes.

### GE04 — Rol, pasiva y cooldown
- Estado: DONE — el HUD presenta rol/pasiva existentes y distingue cooldown recibido como LISTO o BLOQUEADO con etiqueta/símbolo; `sin datos` si no llega. GE04/K04/GE03 PASS.
- Depende de: GE02.
- Aceptación: rol/pasiva y cooldown recibido visibles; listo/bloqueado se distingue sin depender solo del color.

### GE05 — Resultados
- Estado: DONE — tarjeta nueva diferencia resultado de ronda y partida; muestra datos del snapshot sin calcular ganador y desconexión como invalidación; GE05/K04/integración PASS.
- Depende de: GE01.
- Aceptación: ROUND_RESULT distinto a MATCH_RESULT; muestra resultado recibido sin calcular reglas.

### GE06 — Preview y tamaños
- Estado: DONE — cinco estados etiquetados capturados en 1280×720 y 1600×900; verificación geométrica de labels y revisión visual PASS; handoff separa preview simulada de pruebas runtime.
- Depende de: GE01–GE05.
- Aceptación: previews rotulados; capturas a 1280×720/1600×900; handoff separa comprobaciones reales y simuladas.

## TC04 — Contrato visible de rol, pasiva y cooldown
- Estado: DONE — snapshot host por jugador, presentación HUD y casos de dato ausente/inválido verificados; productores de cooldown aún no integrados para todos los roles.
- Depende de: E01–E04, M05, K04.
- Rama sugerida: `Edwar_Estacio/role-state-hud-contract`.
- Verificar que el snapshot autoritativo entregue al HUD el rol, la pasiva y los cooldowns recibidos para los seis roles, sin que la UI recalcule reglas.
- Aceptación: cada jugador muestra contexto coherente con su rol; cooldown listo/bloqueado y tiempo recibido son distinguibles; una ausencia o dato inválido se muestra explícitamente sin fallback engañoso.
- Evidencia requerida: prueba de snapshot/HUD, preview rotulado y handoff de interfaces revisadas.
- Evidencia: `tests/ui/tc04_role_snapshot_hud_test.gd`; preview interactiva rotulada `scenes/ui/tc04_role_state_preview.tscn` y captura `docs/handoffs/evidence/tc04/tc04-role-state-1280x720.png`; handoff de interfaces en `docs/handoffs/2026-10-10-0826-TC04-role-snapshot-hud-contract.md`.

## E05-A — Reloj y contrato autoritativo de olla/escape
- Estado: IN_PROGRESS — duración compartida 20 s, estado de salida serializable, validación/round-trip, señal y barra HUD read-only implementados. M06 debe retirar el reloj paralelo de 30 s e integrar la sesión contra este contrato.
- Depende de: E01–E04.
- Rama sugerida: `Edwar_Estacio/pot-escape-state`.
- Archivos: `scripts/shared/game_rules.gd` (nuevo), `scripts/game/game_state.gd`, `scripts/game/match_state.gd`, `scripts/ui/papoi_hud.gd`, `tests/game/`, `tests/ui/`.
- Crear una única duración compartida de olla de 20 s, estado serializable de disponibilidad de salida y barra HUD read-only del snapshot. `GameState.phase_time_remaining` es el único reloj; no mantener un timer paralelo en HUD ni en `PapoiCookingEscape`.
- Aceptación: estado host pasa POT_COOKING→ESCAPE al llegar el reloj a cero; rescate cancela antes de cero; snapshot round-trip/validación cubre campos nuevos; clientes no cambian autoridad; HUD refleja tiempo y salida sin calcular reglas.

## E05-B — Marcador y resultado según escape confirmado
- Estado: API DONE; decisión confirmada el 2026-10-10 en `docs/specs/POT_ESCAPE_RUNTIME.md`. M06 debe llamar `register_escape(peer_id)` tras validar el cruce autoritativo para completar la ruta runtime.
- Regla: el primer atacante que cruza la salida activa resuelve la ronda y otorga exactamente un punto al equipo; no es necesario que escape todo el equipo. La partida al mejor de cinco termina al alcanzar 3 puntos.
- Depende de: E05-A.
- Rama sugerida: `Edwar_Estacio/escape-scoring`.
- Archivos: `scripts/game/game_state.gd`, `scripts/game/match_state.gd`, `tests/game/`, HUD solo para renderizar el resultado recibido.
- Validar cruce solo en fase `ESCAPE`, rechazo de defensores y cruces duplicados/posteriores, una sola suma por ronda, alternancia de equipos y cierre al llegar a 3.
