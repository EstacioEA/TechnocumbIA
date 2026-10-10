# Handoff — GE05 jerarquía de resultados

- Fecha/hora: 2026-10-10 04:31 (America/Bogota)
- Integrante: Edwar Estacio
- Rama: `Edwar_Estacio/result-hierarchy`
- Objetivo: distinguir ROUND_RESULT de MATCH_RESULT con encabezados y jerarquía visual propios, presentando datos de GameState sin calcular el ganador.
- Archivos modificados: `scripts/ui/papoi_hud.gd`, `scripts/ui/papoi_hud_preview.gd`, `tests/qa/k04_hud_results_test.gd`, specs de Edwar, `AI_TRACE.md`.
- Archivos creados: `scripts/ui/papoi_result_card.gd`, `scenes/ui/papoi_result_card.tscn`, `tests/ui/ge05_result_hierarchy_test.gd`, `docs/handoffs/GE05-round-result-1280x720.png`, `docs/handoffs/GE05-match-result-1280x720.png`, este handoff.

## Resultado

Se añadió el componente reutilizable `PapoiResultCard`. Para resultado de ronda presenta encabezado con número de ronda, ganador recibido, causa de fin recibida y marcador de serie. Para resultado de partida usa un encabezado y tamaño mayores, presenta ganador recibido y marcador final. Si GameState reporta desconexión, el componente muestra `PARTIDA INVALIDADA` con la causa, sin adjudicar victoria.

Los dos resultados consumen los campos existentes del snapshot. La tarjeta solo formatea esos valores; no calcula ganador ni altera reglas.

## Pruebas ejecutadas y resultados reales

| Verificación | Resultado |
|---|---|
| Godot 4.7.2 `--headless --editor --path . --quit` | PASS — escaneo del proyecto y registro de `PapoiResultCard`. |
| Godot 4.7.2 `--headless --path . --script res://tests/ui/ge05_result_hierarchy_test.gd` | PASS — jerarquías, marcador recibido y caso de desconexión. |
| Godot 4.7.2 `--headless --path . --script res://tests/qa/k04_hud_results_test.gd` | PASS — regresión K04 con encabezado, ganador, motivo y marcador separados. |
| Godot 4.7.2 `--headless --path . --script res://tests/game/game_integration_test.gd` | PASS — flujo integrado sigue mostrando resultado autoritativo. |
| Ejecución gráfica de la preview | PASS — capturas de ronda y partida generadas a 1280×720 y revisadas. |
| `git diff --check` | PASS — sin errores de whitespace. |

Capturas de preview con datos simulados:

- [Resultado de ronda — 1280×720](GE05-round-result-1280x720.png)
- [Resultado de partida — 1280×720](GE05-match-result-1280x720.png)

## Decisiones y limitaciones

- Se actualizó la aserción de K04 para verificar por separado los nuevos campos visibles del resultado.
- El marcador mostrado se lee directamente de `scores`; el ganador y el motivo se leen de `round_winner`, `match_winner` y `round_end_reason`.
- Las capturas de la escena de preview son simuladas; el test de integración verifica el resultado de flujo en headless, pero no una partida LAN física.
- No se probó 1600×900. No se creó commit ni se hizo push.

## Siguiente paso

GE06: revisar previews de fases/resultados y escalado a 1280×720 y 1600×900, anotando por separado los datos simulados y los comprobados en runtime.
