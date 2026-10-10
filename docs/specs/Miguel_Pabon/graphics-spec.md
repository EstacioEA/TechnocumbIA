# Spec gráfico — Miguel Pabon

## GM01 — Roles e indicadores de acciones

- Turno: B, al incorporarse Miguel.
- Depende de: G00 y señales/estados de gameplay disponibles.
- Estado: TODO.

### Objetivo y alcance
Ayudar a reconocer los roles y acciones sin añadir reglas. Presentar cooldown y señales de captura, transporte, cocción, rescate, impacto, escape e invalidación/desconexión.

### Archivos permitidos
Nuevos `scenes/ui/role_feedback.tscn`, `scripts/ui/role_feedback.gd`, `assets/ui/roles/`, `assets/ui/feedback/`; `tests/ui/` preview; handoff y `AI_TRACE.md`. Recibe estados/eventos y solo los presenta. No editar combate/roles/GameState ni victoria.

### Aceptación observable
- [ ] Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas tienen nombre e icono distinguible incluso en monocromo.
- [ ] Cooldown listo/bloqueado refleja datos recibidos y el tiempo mostrado.
- [ ] Captura, transporte, cocción, rescate, impacto y escape se reconocen en capturas sin logs.
- [ ] Desconexión no parece resultado de victoria.
- [ ] Efectos no ocultan jugador, Papa, objetivo ni HUD.
- [ ] Handoff incluye hoja de iconos y separa señales conectadas de previews simulados.

### Prompt operativo
> Lee contexto, orquestador, política de ramas, plan gráfico, G00, specs de roles/UI y este spec. Crea únicamente feedback visual que consuma estados existentes. No implementes reglas ni autoridad. Prueba preview, registra señales reales/simuladas, AI_TRACE y handoff con evidencia.
