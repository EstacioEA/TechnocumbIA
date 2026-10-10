# Handoff — K03 cocción, rescate y escape

- Fecha: 2026-10-10
- Integrante: Krystal Giraldo
- Rama: `Krystal_Giraldo/cooking-rescue-escape`
- Rama base: `develop`
- Estado: DONE
- Siguiente tarea recomendada: K04 — HUD y pantallas de resultado.

## Cambios

- `scripts/objectives/papoi_cooking_escape.gd`: coordinador host-autoritativo de cocción, rescate y escape.
- `tests/qa/k03_cooking_escape_test.gd`: prueba headless de la secuencia y guardas.
- `docs/specs/Krystal_Giraldo/TASKS.md`: K03 actualizada a `DONE`.
- `AI_TRACE.md`: entrada incremental local; no se publica remotamente.

## Comportamiento

- Cocción requiere Papa capturada, portador válido, posición dentro de olla y autoridad del host.
- Durante cocción se habilita el acceso de Bestia mediante `BeastAccessState`.
- Bestia solo puede rescatar durante cocción y con acceso activo; el rescate libera Papa y devuelve el objetivo a captura.
- Al completar 30 segundos, Papa pasa a `COOKED`, se cierra el acceso de Bestia y el objetivo cambia a escape.
- `reach_escape()` solo emite `escape_reached` dentro de la zona de base atacante; no adjudica puntos por sí mismo.

## Pruebas

```text
Godot 4.7.2 --headless --path . --script res://tests/qa/k03_cooking_escape_test.gd
K03_COOKING_ESCAPE_TEST: PASS
```

Regresiones adicionales:

```text
K01_MAP_TEST: PASS
K02_POT_ZONE_TEST: PASS
git diff --check: PASS
```

La primera ejecución detectó y corrigió una guarda faltante: Bestia no puede rescatar antes de aparecer. No se creó commit ni se hizo push.

## Riesgos y pendientes

- El host/GameState debe conectar `escape_reached` con `resolve_round(..., ESCAPE_SUCCESS)`; este módulo no inventa ni adjudica victoria.
- Los valores de 30 segundos de cocción y balance de captura siguen siendo constantes explícitas del MVP.
- La validación LAN multiinstancia queda fuera de K03.
