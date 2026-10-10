# Handoff K06 — Remapeo oficial del mapa

- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Rama: `Krystal_Giraldo/official-map-remap`
- Base: `develop` actualizado localmente antes de iniciar el remapeo.
- Autorización: la participante eligió explícitamente `full_remap` para alinear el prototipo runtime con `assets/maps/Mapa Base.jpeg`.

## Decisión de layout

- Hall de Auditorios: base atacante y zona de escape.
- Piedritas: corredor central.
- Summan: zona de captura/aproximación.
- Torre: sala de la olla y entrada bloqueable de Bestia.
- Biblio: base defensora y spawns defensores.

## Cambios

- `scripts/map/papoi_map.gd`: bounds 1280×720, spawns, zonas, rutas, entrada de Torre y paredes de colisión de la Torre.
- `scenes/map/visuals/papoi_map_visuals.gd`: reemplazo de bloques abstractos por la referencia JPEG escalada al viewport y rutas semitransparentes.
- `scenes/map/visuals/papoi_base_spawn_visuals.gd`: bases y marcadores reubicados.
- `scenes/map/visuals/papoi_pot_barrier_visuals.gd`: olla y barrera reubicadas en Torre.
- `scenes/map/papoi_map.tscn`: restauración de la capa visual GK03 preservada.
- `tests/qa/k01_map_test.gd` y `tests/qa/k02_pot_zone_test.gd`: posiciones de regresión adaptadas al layout oficial.

## Verificación

- `K01_MAP_TEST: PASS`
- `K02_POT_ZONE_TEST: PASS`
- `K03_COOKING_ESCAPE_TEST: PASS`
- `GK01_MAP_VISUALS_TEST: PASS`
- `GK02_BASE_SPAWN_VISUALS_TEST: PASS`
- `GK03_POT_BARRIER_VISUALS_TEST: PASS`
- `git diff --check`: PASS
- Captura runtime cerrada: `docs/handoffs/captura vista fix krystal 4.png`.

## Limitaciones y siguiente evidencia

- La captura cerrada valida visualmente GK01 y GK02: landmarks, rutas, bases, spawns y olla en Torre son legibles.
- Captura runtime abierta: `docs/handoffs/captura pantalla krystal 5 - estado abierto.png`.
- Con ambas capturas, GK01, GK02, GK03 y K06 quedan listas para revisión del equipo.
- La imagen se usa como referencia visual proporcionada por el equipo; no se afirma licencia externa.
- No se creó commit ni se hizo push automáticamente.
