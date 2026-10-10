# Spec individual — Miguel Pabon

## Rol
Roles, captura de Papa, combate, cooldowns, vidas, trampas y Bestia.

## Objetivo
Implementar las interacciones principales de ataque y defensa sin duplicar la autoridad del host.

## Alcance
- Asignar roles defensivos: Papa, Trolazzo y Bestia.
- Asignar pasivas atacantes: Tanque, Cazador y Porta Papas.
- Implementar captura de Papa e inmovilización inicial de 20 segundos.
- Implementar reducción de inmovilización por sprints del Porta Papas mediante una constante explícita.
- Implementar soltar Papa y aturdimiento de 3 segundos al portador.
- Implementar golpe a portador: suelta Papa sin perder vida.
- Implementar golpe a atacante sin Papa: pierde una vida y reaparece en 3 segundos.
- Implementar aparición de Bestia a los 30 segundos.
- Implementar ataque básico, ataque especial y cooldowns host-autoritativos.
- Bloquear entrada de Bestia a la sala de olla fuera de cocción.
- Implementar enfurecimiento de Bestia tras cocción: cooldowns reducidos y boost.
- Implementar una trampa MVP del Trolazzo y resistencia/reducción del Tanque.

## Archivos permitidos
- `scripts/roles/`
- `scripts/combat/`
- `scripts/abilities/`
- `scenes/roles/`
- `tests/combat/`
- `docs/handoffs/`
- `AI_TRACE.md`

## Requisitos funcionales
1. Todas las acciones con impacto de juego se validan en el host.
2. Los cooldowns se almacenan como tiempo restante y no pueden ser negativos.
3. Las vidas se reinician al comenzar cada ronda.
4. El rol Papa no puede moverse durante su inmovilización.
5. La Bestia no puede atacar antes de aparecer.
6. Las reglas no deben depender de nombres visuales de nodos.

## Criterios de aceptación
- [ ] Los seis jugadores reciben roles/pasivas visibles al iniciar ronda.
- [ ] Papa queda inmovilizada al ser capturada y el estado se replica a clientes.
- [ ] Un golpe al portador produce soltar Papa y aturdimiento sin quitar vida.
- [ ] Un golpe a atacante sin Papa reduce exactamente una vida y programa respawn de 3 segundos.
- [ ] Bestia aparece después de 30 segundos, no antes.
- [ ] Bestia no atraviesa la barrera de la olla fuera de cocción.
- [ ] Los cooldowns bloquean el uso repetido hasta expirar.
- [ ] Tanque, Cazador y Porta Papas tienen al menos un efecto verificable en el MVP.

## Entregable de sesión
Crear handoff con tabla de estados, números usados, pruebas ejecutadas y decisiones de balance pendientes.

## Prompt para la CLI

> Lee `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/specs/02-round-roles-abilities.md`, `docs/specs/00-game-general.md`, este spec y el handoff más reciente. Implementa únicamente roles, pasivas, captura de Papa, golpes, vidas, respawn, cooldowns, Bestia y una trampa MVP en Godot 4. El host debe validar todas las acciones. No inventes valores distintos a los documentados; si falta un valor, crea una constante temporal y registra la decisión en el handoff. Evita modificar red o HUD salvo interfaces mínimas necesarias. Ejecuta pruebas de estados y cooldowns, revisa el diff, crea handoff y añade una entrada incremental a `AI_TRACE.md`.
