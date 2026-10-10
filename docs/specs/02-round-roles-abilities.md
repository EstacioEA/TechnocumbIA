# Spec modular — Ronda, roles y habilidades

## Roles atacantes
Todos son corredores. Cada uno recibe una pasiva aleatoria:
- **Tanque:** resistencia o reducción definida frente a trampas.
- **Cazador:** habilidad de contrarrestar a Bestia.
- **Porta Papas:** sprint; cada sprint válido reduce el tiempo de inmovilización de Papa.

## Roles defensores
- **Papa:** objetivo móvil; puede escapar antes de ser capturada.
- **Trolazzo:** manipula el mapa mediante trampas con cooldown.
- **Bestia:** aparece a los 30 segundos, ataca con básico y especial.

## Secuencia de victoria atacante
1. Capturar a Papa.
2. Transportarla hasta la olla.
3. Mantener la Papa en la olla hasta cocinarla, salvo rescate de Bestia.
4. Volver a la base atacante y escapar.

## Reglas de control
- Captura: Papa queda inmovilizada 20 segundos; el contador puede reducirse por sprints del Porta Papas.
- Soltar: el portador queda aturdido 3 segundos.
- Golpe a portador: suelta Papa, no pierde vida.
- Golpe a atacante sin Papa: pierde una vida y reaparece en base en 3 segundos.
- La Bestia no puede entrar en la sala de la olla hasta que comience la cocción.
- Tras cocinarse Papa, Bestia entra en enfurecimiento, reduce cooldowns y desbloquea boost.

## MVP de habilidades
Para evitar sobrealcance, cada rol debe tener como máximo una acción activa y un cooldown visible en la primera versión. Las variantes avanzadas se dejan como P2.

## Acceptance criteria
- Cada jugador tiene un rol y una pasiva/estado visible.
- Cooldowns se calculan en el host y se muestran en clientes.
- La ronda no puede terminar por una condición no definida en el spec general.
