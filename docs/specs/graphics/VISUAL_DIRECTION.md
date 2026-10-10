# G00 — Contrato visual compartido

- Responsable: Edwar Estacio
- Revisión de menú/lobby: Juan Diego Balanta
- Estado: TODO
- Dependencias: ninguna

## Base visual

- Resolución de diseño: 1280×720; usar anchors/contenedores para 1600×900 y 1920×1080.
- Estilo: 2D arcade, familiar y legible; siluetas y zonas de juego por encima de decoración.
- Theme compartido: `scenes/ui/papoi_theme.tres`.
- Paleta UI provisional confirmada por el equipo y derivada de los assets: panel `#21161E`, texto `#EDCA96`, acento `#F6B951`, alerta `#B62A2A` (solo relleno, nunca texto sobre el panel), borde `#E38452`. El peligro debe incluir icono o etiqueta además del color. El Theme define tokens centralizados y evita colores sueltos.
- Los colores del mapa y personajes se documentan como muestras JPEG aproximadas; el asset original manda si hay discrepancia. Mapa: follaje `#0E4F22`, `#397823`, `#629C2E`; adoquín `#D0A57C`; ladrillo `#E38452`, `#76412E`; farol `#F6B951`. Personajes: pelaje de Bestia `#85333D`, `#632531`, `#371219`; sudadera/contorno `#21161E`; jean `#384660`; Papa `#D5993F`, `#B27433`, `#E0A752`, contorno `#341408`. Acentos de elenco: rojo `#B62A2A`, azul `#2E9CC1`, verde `#73B161`, lila `#B490D1`.
- La paleta de UI no usa verde. Equipos no se identifican con verde ni marrón y ningún estado crítico depende solo del color.
- Tokens UI implementados en `scenes/ui/papoi_theme.tres`; la muestra interactiva está en `scenes/ui/papoi_theme_preview.tscn`.
- G00 y `project.godot` fijan actualmente 1280×720. La propuesta de diseño de una base 480×270 con escalado entero sigue pendiente de conciliación con 1600×900 y 1920×1080; GE01 no cambia la resolución del proyecto.
- La densidad de píxel de mapa, sprites y HUD aún requiere revisión conjunta. Los JPEG de sheets con tablero horneado deben exportarse con alfa real antes de integrarlos.
- Controles con estados normal/hover/pressed/disabled y foco de teclado visible. Usar fuente incluida con Godot hasta que el equipo aporte una aprobada.
- No comunicar roles/equipos solo mediante color. Usar también texto, icono o forma. Overlay nunca cubre HUD ni mensajes críticos.

## HUD

- Barra superior de 6–8 % de alto para fase/objetivo, temporizadores y marcador; fondo oscuro.
- Panel compacto, sólido y alineado abajo a la izquierda para rol, pasiva, vidas y cooldowns, con márgenes de 2–3 %.
- Resultados en modal central con overlay oscuro cercano al 60 %; HUD permanece por encima y legible.
- Usar `Control`, anchors y containers para el layout, sin posiciones absolutas.
- Si no hay dato de cooldown, mostrar `sin datos`. El HUD solo presenta la señal/datos recibidos y no calcula cooldowns. `TODO(GM01)`: Miguel debe confirmar publicación y formato (segundos, fracción o ticks); interfaz prevista `cooldown_changed(slot, remaining, total)`.

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

