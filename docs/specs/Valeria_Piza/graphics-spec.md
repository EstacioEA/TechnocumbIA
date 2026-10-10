# Spec gráfico — Valeria Piza

## Turno B — Valeria Piza

Usa el contrato provisional G00 y no espera que Edwar termine el Theme.

### GV01 — Siluetas y equipos
- Estado: DONE; depende de: escena de jugador disponible.
- Archivos: `assets/characters/players/` nuevo; nodo visual aislado en `scenes/player/`.
- Aceptación: dos siluetas/equipos distinguibles mediante color y forma/marca; captura superpuesta al mapa; colisión intacta.

### GV02 — Orientación y jugador local
- Estado: DONE; depende de: GV01.
- Archivos: componente visual de jugador y preview.
- Aceptación: dirección de movimiento legible y jugador local marcado sin tapar sprite; se diferencia local/remoto en captura.

### GV03 — Variantes y preview de seis jugadores
- Estado: DONE; depende de: GV01, GV02.
- Archivos: assets propios y `tests/ui/`.
- Aceptación: seis instancias visibles a escala real, distinción de equipo/local a visión encendida y apagada, sin cambiar spawn/input/collider; captura y procedencia de assets en handoff.

### TC01 — Avatares con sprites
- Estado: DONE; depende de: GV01–GV03, M01.
- Integración: los roles Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas usan
  el primer cuadro de su sheet de personaje en `PlayerVisual`; el marcador de
  equipo/local permanece separado del avatar.
- Procedencia: sheets proporcionados por el equipo en `assets/characteres/`; no se
  incorporaron assets de terceros durante esta tarea.

### Reglas
No editar movimiento, cámara, colisiones ni sincronización. Si la integración necesita esos scripts, solicitar interfaz al responsable y dejarla como pendiente, sin bloquear las variantes visuales. Por tarea: captura, verificación real, AI_TRACE incremental y handoff.
