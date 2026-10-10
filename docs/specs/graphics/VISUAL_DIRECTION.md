# G00 — Contrato visual compartido

- Responsable: Edwar Estacio
- Revisión de menú/lobby: Juan Diego Balanta
- Estado: TODO
- Dependencias: ninguna

## Base visual

- Resolución de diseño: 1280×720; usar anchors/contenedores para 1600×900 y 1920×1080.
- Estilo: 2D arcade, familiar y legible; siluetas y zonas de juego por encima de decoración.
- Theme compartido: `scenes/ui/papoi_theme.tres`.
- Paleta provisional: fondo `#101923`, panel `#1D2A35`, texto `#F4F1DE`, Papa `#F2C14E`, confirmación `#68D391`, error/desconexión `#F06C62`.
- Controles con estados normal/hover/pressed/disabled y foco de teclado visible. Usar fuente incluida con Godot hasta que el equipo aporte una aprobada.
- No comunicar roles/equipos solo mediante color. Usar también texto, icono o forma. Overlay nunca cubre HUD ni mensajes críticos.

## Estados que deben tener representación inequívoca

| Estado | Tratamiento visible |
|---|---|
| Esperando / listo | Etiqueta persistente y diferencias claras |
| Conectando | Indicador de progreso y texto |
| Rechazo / desconexión | Mensaje con causa resumida |
| Host / cliente | Etiqueta e icono |
| Rol / pasiva | Nombre e icono |
| Acción disponible / cooldown | Diferencia visible y tiempo recibido |
| Fase / objetivo / resultado | Texto más icono; distinguir resultado de ronda y de partida |

## Aceptación

- [ ] Theme existe y se usa al menos en una pantalla del Turno A.
- [ ] Captura/muestras muestran los colores, foco y estados anteriores.
- [ ] Sin texto cortado/solapado en 1280×720, 1600×900 y 1920×1080.
- [ ] Juan registra su revisión del flujo en el handoff G00.

