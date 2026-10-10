# Spec gráfico — Krystal Giraldo

## GK01 — Lectura visual del mapa y sus zonas

- Turno: B, al incorporarse Krystal.
- Depende de: G00 y mapa funcional existente.
- Estado: TODO.

### Objetivo y alcance
Hacer reconocibles las dos bases, rutas, sala de olla, barrera, límites y spawns, conservando navegación/colisiones. Integrar recursos aprobados por el equipo; si faltan, usar placeholders propios.

### Archivos permitidos
Nodos visuales de `scenes/map/papoi_map.tscn`; nuevos `scenes/map/visuals/`, `assets/map/`; `tests/qa/` para evidencia; handoff y `AI_TRACE.md`. No cambiar zonas, spawns, colisiones ni reglas.

### Aceptación observable
- [ ] Captura completa identifica bases, rutas, olla, barrera y spawns con forma/icono/etiqueta.
- [ ] Ruta transitable contrasta con decoración y fondo.
- [ ] Barrera de olla se distingue abierta/cerrada.
- [ ] Overlay no oculta objetivos ni HUD.
- [ ] Pruebas existentes de mapa/colisión mantienen resultados.
- [ ] Handoff incluye captura 1280×720 y procedencia/licencia de cada asset.

### Prompt operativo
> Lee contexto, orquestador, política de ramas, plan gráfico, G00, spec de mapa/cámara y este spec. Mejora solo apariencia/lectura visual, conserva geometría y colisiones. Ejecuta pruebas de mapa disponibles, registra AI_TRACE y handoff con captura, procedencia y resultados reales.
