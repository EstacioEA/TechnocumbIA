# Handoff — GK02 bases y spawns

- Fecha: 2026-10-10
- Turno: B
- Integrante: Krystal Giraldo
- Rama: `Krystal_Giraldo/base-spawn-visuals`
- Rama base: `develop`
- Estado: IN_PROGRESS
- Siguiente tarea recomendada: completar revisión visual de GK01/GK02 y después GK03.

## Cambios

- `scenes/map/visuals/papoi_base_spawn_visuals.gd`: visuales originales para bases, spawns de atacantes/defensores, Papa y Bestia.
- `scenes/map/visuals/papoi_base_spawn_visuals.tscn`: escena visual independiente.
- `scenes/map/papoi_map.tscn`: instancia la capa sin modificar el mapa lógico.
- `tests/qa/gk02_base_spawn_visuals_test.gd`: valida la capa, los grupos de marcadores y la conservación de coordenadas lógicas.
- `docs/specs/Krystal_Giraldo/TASKS.md`: GK02 queda `IN_PROGRESS`, no `DONE`, por falta de captura/revisión visual.

## Pruebas

```text
Godot 4.7.2 --headless --path . --script res://tests/qa/gk02_base_spawn_visuals_test.gd
GK02_BASE_SPAWN_VISUALS_TEST: PASS

Godot 4.7.2 --headless --path . --script res://tests/qa/gk01_map_visuals_test.gd
GK01_MAP_VISUALS_TEST: PASS

Godot 4.7.2 --headless --path . --script res://tests/qa/k01_map_test.gd
K01_MAP_TEST: PASS

git diff --check
PASS
```

## Alcance y seguridad

- No se movieron coordenadas lógicas ni se modificaron límites, colisiones, zonas u objetivos.
- Los equipos se distinguen por etiqueta, forma y color; no dependen solo del color.
- Se usaron formas y colores originales; no se afirma autorización legal de arte externo.

## Bloqueo

La aceptación visual requiere captura/revisión de las bases y spawns. Esta sesión solo ejecutó Godot headless, por lo que GK02 permanece `IN_PROGRESS`.

- No se creó commit ni se hizo push.
