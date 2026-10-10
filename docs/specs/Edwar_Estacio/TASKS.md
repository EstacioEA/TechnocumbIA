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
- Estado: TODO; depende de: GE02.
- Aceptación: rol/pasiva y cooldown recibido visibles; listo/bloqueado se distingue sin depender solo del color.

### GE05 — Resultados
- Estado: TODO; depende de: GE01.
- Aceptación: ROUND_RESULT distinto a MATCH_RESULT; muestra resultado recibido sin calcular reglas.

### GE06 — Preview y tamaños
- Estado: TODO; depende de: GE01–GE05.
- Aceptación: previews rotulados; capturas a 1280×720/1600×900; handoff separa comprobaciones reales y simuladas.
