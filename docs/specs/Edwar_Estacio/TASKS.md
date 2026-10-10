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
- Estado: TODO
- Depende de: E03, J03, M02, K03, V02
- Rama sugerida: `Edwar_Estacio/game-integration`
- Integrar contratos sin asumir estados locales y ejecutar smoke test de una ronda.
- Aceptación: el flujo completo arranca, llega a resultado o registra bloqueo reproducible; no rompe módulos existentes.
