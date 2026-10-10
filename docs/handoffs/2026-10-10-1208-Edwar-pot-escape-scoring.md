# Handoff — decisión de puntuación de olla y escape

- Fecha/hora: 2026-10-10 12:08 America/Bogota
- Integrante: Edwar Estacio
- Rama: `develop`
- Objetivo: registrar la regla confirmada para determinar cuándo ganan los atacantes la ronda y actualizar el reparto técnico.
- Archivos modificados: `docs/specs/POT_ESCAPE_RUNTIME.md`, `docs/TASK_BOARD.md`, `docs/specs/Edwar_Estacio/TASKS.md`, `docs/specs/Juan_Balanta/TASKS.md`, `AI_TRACE.md`.

## Decisión

El primer atacante que cruce la salida habilitada durante `ESCAPE` gana la ronda. Basta una persona; no se requiere que escapen los tres atacantes. El equipo atacante recibe exactamente un punto por esa ronda. Los cruces posteriores no otorgan puntos adicionales ni vuelven a resolverla. Se mantiene la partida al mejor de cinco, con victoria al alcanzar tres puntos.

## Cambios documentales

- La spec define el primer cruce válido como resultado autoritativo del host y elimina la necesidad de una lista serializada de atacantes escapados.
- E05-B ahora está READY y debe validar la suma única, los rechazos por rol/fase/duplicado, alternancia y fin a tres puntos.
- J05 ahora puede verificar un único punto replicado y el resultado de ronda en los seis peers.
- El tablero de tareas refleja la decisión y dependencias actualizadas.

## Validación y límites

- `git diff --check`: PASS.
- Pruebas de Godot: no ejecutadas; solo cambiaron documentos.
- No se modificó código de gameplay ni entradas previas de `AI_TRACE.md`.
- No se creó commit.

## Siguiente paso

Implementar E05-A/E05-B en una rama de funcionalidad conforme a la política de ramas y ejecutar las pruebas del estado autoritativo antes de integrar M06/J05.
