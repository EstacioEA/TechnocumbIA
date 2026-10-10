# Spec gráfico — Juan Diego Balanta

## GJ01 — Menú inicial y lobby LAN

- Turno: A con Edwar; revisión final en Turno C.
- Depende de: G00 (`docs/specs/graphics/VISUAL_DIRECTION.md`).
- Estado: TODO.

### Objetivo
Que una persona entienda cómo crear o unirse a una partida y lea el estado del lobby sin consultar logs.

### Alcance
Menú con Host/Unirse/Salir; campos IP/puerto y validación inline; estados conectando/conectado/rechazo/desconexión; seis slots con nombre/peer, ready y Host; inicio visible solo para host; navegación con mouse y foco de teclado.

### Archivos permitidos
`scenes/lobby/`, `scripts/ui/lobby/`, nuevos `scenes/menu/`, nuevos `scripts/ui/menu/`, `tests/ui/`, `docs/handoffs/`, `AI_TRACE.md`. No alterar protocolo/autoridad de `NetworkManager`. Coordinar antes de cambiar una interfaz compartida.

### Aceptación observable
- [ ] Ejecutar el proyecto muestra menú y acciones Host/Unirse reconocibles.
- [ ] IP/puerto inválidos y errores de conexión se muestran en pantalla.
- [ ] Lobby muestra seis slots y estados reales de ready/desconexión.
- [ ] Cliente entiende que no puede iniciar; host ve si puede iniciar.
- [ ] Foco visible y acciones principales navegables por teclado.
- [ ] Capturas de lobby vacío, parcial, lleno, no listo y desconectado.
- [ ] Capturas a 1280×720 y 1600×900; datos preview rotulados si no vienen de runtime.

### Prompt operativo
> Lee contexto, orquestador, política de ramas, plan gráfico, G00, spec de UI y este spec. Implementa solo GJ01 en los archivos permitidos, mantén la red/GameState como autoridad, prueba visualmente y deja capturas, resultados reales, AI_TRACE incremental y handoff. No presentes datos de preview como reales.
