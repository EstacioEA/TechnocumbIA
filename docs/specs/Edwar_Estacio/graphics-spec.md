# Spec gráfico — Edwar Estacio

## Turno A — Edwar Estacio

Edwar mantiene sus archivos de Theme/HUD separados de los archivos de menú/lobby de Juan. Juan puede terminar su turno sin esperar estas tareas; su revisión del Theme será recomendación para GINT, no gate para GJ01–GJ05.

### GE01 — Recurso Theme
- Estado: DONE — Theme y escena de preview cargan en Godot 4.7.2 headless; revisión visual interactiva queda pendiente para QA global G00/GE06.
- Depende de: ninguna.
- Archivos: `scenes/ui/papoi_theme.tres`, `scenes/ui/papoi_theme_preview.tscn`, `docs/specs/graphics/VISUAL_DIRECTION.md`.
- Aceptación: paleta provisional, estilos normal/hover/pressed/disabled y foco visible implementados en Theme; una preview permite ver sus controles.

### GE02 — Jerarquía base del HUD
- Estado: DONE — K04 PASS y capturas revisadas a 1280×720; overlay de resultado conserva el HUD visible.
- Depende de: GE01.
- Archivos: `scenes/ui/papoi_hud.tscn`, `scripts/ui/papoi_hud.gd` solo presentación, `scenes/ui/papoi_hud_preview.tscn`, `scripts/ui/papoi_hud_preview.gd` y captura de handoff.
- Aceptación: fase/objetivo, timers, marcador, vidas y contexto de jugador agrupados en orden legible; overlay no tapa el HUD; captura en 1280×720.

### GE03 — Presentación de fase y temporizadores
- Estado: DONE — ACTIVE, POT_COOKING y ESCAPE diferenciados visualmente; timer de ronda separado del de cocción; prueba GE03 y regresión K04 PASS; previews capturadas a 1280×720.
- Depende de: GE02.
- Archivos: HUD UI y pruebas/preview UI.
- Aceptación: ACTIVE, POT_COOKING y ESCAPE se distinguen; timer de cocción no se confunde con timer de ronda; runtime usa señales/datos ya existentes.

### GE04 — Contexto de rol y cooldowns
- Estado: DONE — rol/pasiva del snapshot y estados LISTO/BLOQUEADO diferenciados con texto e icono cuando llegan cooldowns numéricos; sin datos muestra `sin datos`; GE04/K04/GE03 PASS.
- Depende de: GE02.
- Archivos: HUD UI; no editar `scripts/roles/` ni `scripts/combat/`.
- Aceptación: rol/pasiva y cooldown recibido visibles; disponible/bloqueado se distingue con icono/etiqueta y no solo color.

### GE05 — Resultados
- Estado: DONE — nueva tarjeta separa jerárquicamente resultado de ronda y de partida, muestra ganador/motivo/marcador del snapshot y distingue desconexión; GE05, K04 e integración PASS; capturas 1280×720 revisadas.
- Depende de: GE01.
- Archivos: componentes UI nuevos bajo `scenes/ui/` y enlaces visuales al HUD existente.
- Aceptación: ROUND_RESULT y MATCH_RESULT tienen encabezado y jerarquía distintos y muestran datos proporcionados por GameState; no calculan ganador.

### GE06 — Preview y escalado
- Estado: TODO; depende de: GE01–GE05.
- Archivos: `tests/ui/`, handoff y `AI_TRACE.md`.
- Aceptación: previews etiquetados de cinco fases/resultados; captura en 1280×720 y 1600×900; no hay texto recortado. Separar pruebas de preview y runtime en el handoff.

### Reglas y prompt operativo
Leer contexto, orquestador, política de ramas, plan visual, G00 y spec UI. Implementar cada subtask sin cambiar `GameState`, reglas o red; probar lo correspondiente y guardar capturas. Juan no necesita aprobar ni integrar GE01 para avanzar con menú/lobby. Registrar AI_TRACE y handoff incremental.
