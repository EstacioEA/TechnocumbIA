# Handoff — reparto de implementación: olla, rescate y escape

- Fecha/hora: 2026-10-10 12:02 America/Bogota
- Participante: Edwar Estacio
- Rama: `develop`
- Base: `23fd0a7`, fast-forward de `origin/develop`; árbol limpio antes de modificar docs. No se creó commit.
- Objetivo: convertir la solicitud del equipo sobre cocinar a Papa, rescate de Bestia y salida izquierda en tareas atómicas asignadas a Juan, Valeria, Miguel y Edwar.
- Archivos modificados: `docs/specs/POT_ESCAPE_RUNTIME.md`, `docs/TASK_BOARD.md`, cuatro archivos `docs/specs/<integrante>/TASKS.md`, `AI_TRACE.md` y este handoff.

## Resultado de revisión

- K02/K03 y M02/M04 reportan componentes y pruebas headless unitarias DONE; eso no acredita por sí solo la ruta interactiva completa dentro de seis peers LAN.
- `GameState` y `PapoiCookingEscape` tienen duración independiente de 30 segundos. La nueva solicitud especifica 20 segundos.
- El GameSession conecta parte del recorrido: el portador puede empezar cocción al interactuar en olla, Bestia puede rescatar y el portador puede activar escape. Falta verificarlo en runtime integrado.
- El escape actual valida al portador y resuelve una ronda por un solo cruce; no mantiene un conteo serializable de todos los atacantes escapados ni expresa la salida izquierda como activada/inactiva en el mapa.
- `POT_ZONE` y `ESCAPE_ZONE` ya existen en `PapoiMap`; el spec prohíbe duplicar/reubicar geometría.

## Reparto acordado en documentos

- **Edwar E05-A/B:** timer único de 20s, contrato serializable y barra HUD read-only; marcador/resolución se bloquea hasta decidir semántica de puntos.
- **Valeria V06:** indicador visual de salida cerrada/activa y prueba de recorrido, sin alterar geometría/colisiones del mapa.
- **Miguel M06:** integrar depósito por interacción, liberación de Papa, rescate contextual de Bestia, transición y validación de posiciones host-side.
- **Juan J05:** runner de integración con host + cinco clientes; comprobar estados replicados y cierre limpio sin escribir estado desde clientes.

## Decisión de diseño pendiente

La frase “un punto por atacante escapado” requiere aclarar cómo se combina con marcador al mejor de cinco y victoria a tres puntos, sobre todo si escapan uno o dos atacantes. El spec registra dos alternativas; E05-B y la aserción de score de J05 permanecen BLOCKED hasta que el equipo elija.

## Verificación y límites

- `git diff --check`: PASS.
- No se ejecutaron pruebas; el cambio produce especificación y reparto, no código de gameplay.
- No se tocó `/error` ni se alteró evidencia previa.
- El árbol tenía cambios documentales planeados al cerrar; no se creó commit ni push.

## Siguiente paso

El equipo confirma la regla de marcador A/B. Edwar publica E05-A, Valeria puede empezar V06 en paralelo; Miguel espera el contrato E05-A, y Juan comienza J05 tras la integración M06/V06.
