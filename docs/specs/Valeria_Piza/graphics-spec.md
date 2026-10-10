# Spec gráfico — Valeria Piza

## GV01 — Siluetas y orientación de jugadores

- Turno: B, al incorporarse Valeria.
- Depende de: G00 y escena de partida disponible.
- Estado: TODO.

### Objetivo y alcance
Hacer distinguibles seis jugadores sobre el mapa y marcar el jugador local sin cambiar input, movimiento, colisiones ni autoridad. Usar variantes ligeras o placeholders originales.

### Archivos permitidos
Nodos de presentación en `scenes/player/` preservando scripts/colliders; nuevos `assets/characters/players/`; escena/preview en `tests/ui/`; handoff y `AI_TRACE.md`. No editar scripts de movimiento/cámara/sync sin coordinación.

### Aceptación observable
- [ ] Preview enseña seis avatares a escala de gameplay.
- [ ] Equipos distinguidos por color y forma/marca; jugador local con contorno/marcador.
- [ ] Orientación/dirección legible; HUD permanece encima del overlay.
- [ ] Apariencias no cambian tamaño de colisión ni spawn.
- [ ] Captura de los seis sobre el mapa y notas de placeholders/licencias en handoff.

### Prompt operativo
> Lee contexto, orquestador, política de ramas, plan gráfico, G00, specs de mapa/cámara y este spec. Implementa solo presentación de personajes; conserva movimiento, autoridad y colisiones. Prueba seis instancias con overlay, registra AI_TRACE y handoff con captura y defectos visuales.
