# Spec general — Papoi

## Propósito
Permitir una partida LAN 3v3 en la que los atacantes capturen, cocinen y entreguen a la Papa mientras los defensores impiden la secuencia.

## Usuarios
Seis jugadores en Windows conectados a la misma red local; un jugador actúa como host.

## Requisitos funcionales
1. Crear o unirse a una partida mediante IP y puerto.
2. Esperar hasta seis jugadores y asignarlos a dos equipos de tres.
3. Asignar ataque/defensa inicialmente de forma aleatoria.
4. Alternar lados entre rondas hasta que un equipo alcance tres puntos.
5. Asignar a atacantes la pasiva Tanque, Cazador o Porta Papas.
6. Asignar a defensores los roles Papa, Trolazzo y Bestia.
7. Ejecutar rondas de máximo siete minutos.
8. Permitir movimiento de teclado e interacción contextual.
9. Permitir capturar, transportar, soltar y cocinar la Papa.
10. Permitir que los defensores golpeen, coloquen trampas o usen habilidades según rol.
11. Aplicar vidas, respawn, cooldowns, estados de control y reglas de zona.
12. Mostrar fase, tiempo, puntos, vidas y estados relevantes.
13. Declarar ganador de ronda y partida de manera determinista.

## Estados de ronda
`LOBBY`, `COUNTDOWN`, `ACTIVE`, `POT_COOKING`, `ESCAPE`, `ROUND_RESULT`, `MATCH_RESULT`.

## Edge cases
- Un jugador desconecta: el host cancela la ronda o marca la partida no válida; no se permite continuar silenciosamente con estado incompleto.
- El host desconecta: cerrar partida y mostrar mensaje de reconexión no soportada para MVP.
- Dos jugadores intentan capturar simultáneamente: el host resuelve por orden de llegada.
- La Papa recibe impacto durante transporte: se suelta y el portador no pierde vida.
- Un atacante recibe impacto sin Papa: pierde una vida y reaparece tras 3 segundos.
- El tiempo llega a cero: ganan defensores, salvo que la partida ya esté en una transición válida.
- Todos los atacantes pierden sus vidas: ganan defensores.
- La Bestia intenta entrar a la olla fuera de cocción: colisión o barrera la bloquea.

## Acceptance criteria
- **Given** seis clientes conectados, **When** el host inicia, **Then** existen dos equipos de tres con roles visibles.
- **Given** una ronda activa, **When** un atacante captura a Papa, **Then** Papa entra en estado inmovilizado durante 20 segundos o el tiempo reducido por sprints.
- **Given** Papa está en transporte, **When** el portador recibe un golpe, **Then** Papa queda en el mapa y el portador sigue vivo.
- **Given** un atacante sin Papa recibe un golpe válido, **When** el host procesa el impacto, **Then** pierde exactamente una vida y reaparece tras 3 segundos.
- **Given** Papa está en la olla, **When** termina el tiempo de cocción sin rescate, **Then** basta que el primer atacante cruce la salida de su base para ganar la ronda y sumar un punto al equipo.
- **Given** la Bestia está fuera de fase de cocción, **When** intenta cruzar la entrada de la olla, **Then** no puede entrar.
- **Given** un equipo alcanza tres rondas ganadas, **When** termina la ronda, **Then** la partida finaliza y no inicia una sexta ronda.
