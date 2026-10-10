# Spec gráfico — Krystal Giraldo

## Turno B — Krystal Giraldo

Puede iniciar al recibir el plan G00; no depende de la finalización del Theme ni de la UI de lobby.

### GK01 — Paleta de suelo y caminos
- Estado: TODO; depende de: mapa funcional existente.
- Archivos: nodos/capas visuales bajo `scenes/map/visuals/` y `assets/map/`.
- Aceptación: rutas transitables contrastan con suelo/decoración; las paredes no parecen caminos; captura de mapa completo.

### GK02 — Marcas de bases y spawns
- Estado: TODO; depende de: ninguna (puede hacerse en paralelo con GK01 usando archivos visuales separados).
- Archivos: assets/nodos visuales de base/spawn, sin editar sus coordenadas lógicas.
- Aceptación: ambas bases y spawns identificables por icono/forma/etiqueta; comprobación lado atacante/defensor.

### GK03 — Olla, barrera y señal de objetivo
- Estado: TODO; depende de: G00 (tokens provisionales disponibles inmediatamente).
- Archivos: componente visual de olla/barrera y assets relacionados.
- Aceptación: Papa/olla se reconoce; abierto/cerrado se distingue; visuales no cambian zona, colisión ni estado de objetivo.

### GK04 — Contraste y evidencia del mapa
- Estado: TODO; depende de: GK01–GK03.
- Archivos: `tests/qa/`, handoff y `AI_TRACE.md`.
- Aceptación: capturas con overlay activo/inactivo, HUD legible, zonas y caminos claros a 1280×720; pruebas existentes de mapa conservadas; licencia/procedencia anotada.

### Reglas
No modificar geometría, spawns lógicos, colisiones ni objetivos. Usar assets del equipo con procedencia conocida o placeholders originales. Entregar captura y handoff por el conjunto terminado.
