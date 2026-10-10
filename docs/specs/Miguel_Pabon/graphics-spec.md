# Spec gráfico — Miguel Pabon

## Turno B — Miguel Pabon

Usa los colores/iconos provisionales G00; puede producir recursos aun si los eventos reales todavía no están conectados.

### GM01 — Iconos de roles y pasivas
- Estado: TODO; depende de: ninguna.
- Archivos: `assets/ui/roles/` nuevo y preview en `tests/ui/`.
- Aceptación: icono y nombre para Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas; se distinguen en monocromo y a tamaño HUD.

### GM02 — Indicadores de cooldown/acción
- Estado: TODO; depende de: GM01 para reutilizar el mismo vocabulario visual.
- Archivos: `assets/ui/feedback/` y componente UI separado.
- Aceptación: disponible, bloqueado y cuenta regresiva recibida son estados visuales distintos; sin introducir cálculos de cooldown.

### GM03 — Estados de Papa y objetivo
- Estado: TODO; puede correr en paralelo con GM01, en archivos propios.
- Archivos: componentes/íconos de feedback Papa/objetivo.
- Aceptación: capturada, transportada, en olla/cocinándose, rescatada y escapada tienen feedback visible diferenciado.

### GM04 — Impactos, desconexión y hoja de preview
- Estado: TODO; depende de: GM02 y GM03.
- Archivos: `scenes/ui/role_feedback.tscn`, `scripts/ui/role_feedback.gd`, `tests/ui/`.
- Aceptación: impacto/acción y desconexión visibles sin confundirse con victoria; hoja de preview indica qué señales son reales y cuáles simuladas; efectos no cubren jugador, Papa ni HUD.

### Reglas
Solo dibuja estados/eventos recibidos; no edita combate, roles, GameState o condiciones de victoria. Registrar capturas, fuentes de assets, AI_TRACE incremental y handoff.
