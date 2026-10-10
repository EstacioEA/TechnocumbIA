# Contexto para CLIs — Papoi

## Competencia
- `TEAM_ID`: TechnocumbIA
- `PARTICIPANT_ID`: Edwar Estacio, Juan Balanta, Valeria Piza, Miguel Pabon, Krystal Giraldo
- `EVENT_ID`: no proporcionado; no inventar un identificador.
- Repositorio: `EstacioEA/TechnocumbIA`
- Plataforma objetivo: Windows
- Motor: Godot 4
- Lenguaje principal: GDScript
- Red MVP: Godot High-Level Multiplayer sobre LAN mediante IP

## Producto
Papoi es un juego 3v3 cooperativo-competitivo en perspectiva 2D con apariencia isométrica. Un equipo atacante captura a un jugador defensor con rol Papa, lo transporta a una olla, completa una cocción y luego escapa a su base. El equipo defensor intenta impedirlo mediante Papa, Trolazzo y Bestia.

## Decisiones funcionales confirmadas
- Cada partida tiene hasta 5 rondas; gana el primer equipo en obtener 3 puntos.
- La primera asignación de ataque/defensa es aleatoria. Después de cada ronda los lados se intercalan.
- Roles defensivos y pasivas atacantes se asignan aleatoriamente y pueden repetirse.
- Cada ronda dura como máximo 7 minutos.
- Atacantes: 3 jugadores, 3 vidas por ronda. Al perder una vida reaparecen en base tras 3 segundos.
- Si un atacante es golpeado llevando la Papa, la suelta sin perder vida.
- Si un atacante es golpeado sin llevar la Papa, pierde una vida.
- Papa queda inmovilizada 20 segundos al ser capturada. Los sprints del Porta Papas reducen ese tiempo.
- Al soltar la Papa, el portador queda aturdido 3 segundos.
- Bestia aparece 30 segundos después del inicio de ronda.
- Bestia no entra a la sala de la olla salvo mientras la Papa se cocina.
- Al cocinarse la Papa, Bestia entra en enfurecimiento: cooldowns reducidos y boost de velocidad.
- MVP de red: host/servidor y clientes conectados por IP en LAN. Online queda fuera del MVP.
- Controles: teclado; acciones mínimas: movimiento, interacción/captura, soltar, ataque/habilidad y trampa según rol.

## Regla para resolver conflictos
En caso de conflicto entre código, handoff y spec, prevalece este orden: decisión de producto más reciente documentada > spec general > spec modular > spec atómico > código existente. Si el conflicto no puede resolverse, detener la implementación y registrar una pregunta en el handoff.

## Límites de IA
La IA puede generar código, pruebas, documentación y propuestas. No debe fabricar evidencia, alterar timestamps, borrar trazabilidad ni afirmar que ejecutó comandos que no ejecutó.
