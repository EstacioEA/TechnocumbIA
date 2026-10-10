# Spec gráfico — Edwar Estacio

## GE01 — Theme, HUD de partida y resultados

- Turno: A con Juan; Edwar lidera G00. Revisión final en Turno C.
- Estado: TODO.

### Objetivo
Definir el estilo visual compartido y mostrar estados existentes de partida con jerarquía clara.

### Alcance y archivos
Definir `docs/specs/graphics/VISUAL_DIRECTION.md`; crear `scenes/ui/papoi_theme.tres`; aplicar Theme a `scenes/ui/papoi_hud.tscn` y `scripts/ui/papoi_hud.gd`; presentar fase, objetivo, timers, marcador, vidas/rol/pasiva/cooldowns y paneles de resultado. `scenes/game/` solo para presentación. No cambiar reglas, cálculos ni `GameState`.

### Aceptación observable
- [ ] G00 define paleta, escala, foco, contraste y tratamiento de estados; Juan revisa menú/lobby.
- [ ] Theme aplicado al HUD o pantalla de juego.
- [ ] Se leen fase, ronda, tiempos, marcador, rol/pasiva, vidas/cooldowns y objetivo sin consola.
- [ ] Timer de cocción se distingue del timer de ronda; resultado de ronda se distingue del de partida.
- [ ] Preview enseña ACTIVE, POT_COOKING, ESCAPE, ROUND_RESULT y MATCH_RESULT y lo identifica como preview.
- [ ] Runtime muestra datos reales; no se duplican reglas en la capa gráfica.
- [ ] Capturas a 1280×720 y 1600×900; overlay no tapa información crítica.

### Prompt operativo
> Lee contexto, orquestador, política de ramas, plan gráfico, G00, spec de UI y este spec. Implementa solo Theme/HUD/resultados en el alcance indicado, conserva el modelo autoritativo, prueba la vista, registra AI_TRACE y handoff con capturas y limitaciones. Marca preview y runtime por separado.
