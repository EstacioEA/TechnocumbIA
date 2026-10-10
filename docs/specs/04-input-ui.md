# Spec modular — Entrada, HUD y flujo de usuario

## Flujo
1. Pantalla inicial: Host, Unirse, IP, puerto y Salir.
2. Lobby: lista de jugadores, estado listo y botón iniciar para host.
3. Countdown de ronda.
4. HUD de partida.
5. Resultado de ronda.
6. Resultado de partida y volver al menú.

## Controles base
- WASD: movimiento.
- E: interacción/captura/soltar según contexto.
- Espacio: sprint o habilidad primaria según rol, con cooldown.
- Q: habilidad secundaria/especial cuando aplique.

## HUD mínimo
Fase, temporizador, puntos de ambos equipos, vidas del atacante local, rol/pasiva, cooldowns y mensajes de objetivo.

## Acceptance criteria
- Todas las acciones mínimas se pueden ejecutar con teclado.
- Un jugador puede conocer su objetivo actual sin leer logs.
- Los errores de conexión se muestran en pantalla.
- El HUD distingue claramente tiempo de ronda y tiempo de cocción.
