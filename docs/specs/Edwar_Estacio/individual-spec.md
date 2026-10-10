# Spec individual — Edwar Estacio

## Rol
Integración, estado autoritativo y flujo completo de partida.

## Objetivo
Construir el núcleo que controla las fases de lobby, ronda, cocción, escape, resultados y marcador, manteniendo al host como autoridad única.

## Alcance
- Crear enums compartidos para `GamePhase`, `TeamSide`, `DefenderRole`, `AttackerPassive`, `PapaState` y `RoundEndReason`.
- Definir una estructura serializable de estado de partida.
- Implementar el ciclo `LOBBY -> COUNTDOWN -> ACTIVE -> POT_COOKING -> ESCAPE -> ROUND_RESULT -> MATCH_RESULT`.
- Implementar marcador al mejor de 5 y finalización al alcanzar 3 victorias.
- Validar en el host las condiciones de victoria y derrota.
- Exponer señales/eventos para que red, HUD, roles y mapa reaccionen sin duplicar reglas.

## Archivos permitidos
- `scripts/game/`
- `scripts/shared/`
- `scenes/game/`
- `tests/game/`
- `docs/handoffs/`
- `AI_TRACE.md`

No modificar contratos de red sin actualizar `docs/specs/01-network-lan.md`.

## Requisitos funcionales
1. El host debe ser la única autoridad que cambia fase, marcador, vidas, estados de Papa y temporizadores.
2. Una ronda no puede iniciar con menos de seis jugadores en el MVP.
3. La asignación inicial de ataque/defensa es aleatoria.
4. Después de cada ronda se intercambian los lados.
5. Los roles y pasivas se asignan al comenzar cada ronda y pueden repetirse.
6. La ronda termina por cocción y escape, eliminación de atacantes, tiempo agotado o desconexión no recuperable.
7. La partida termina inmediatamente cuando un equipo alcanza tres puntos.
8. Toda transición inválida debe rechazarse y registrarse mediante una advertencia técnica.

## Criterios de aceptación
- [ ] Con seis jugadores listos, el host inicia una cuenta regresiva y entra en `ACTIVE`.
- [ ] El host puede iniciar una ronda con equipos, roles y pasivas asignados.
- [ ] El temporizador de ronda llega como máximo a siete minutos y produce resultado si expira.
- [ ] El marcador se incrementa exactamente una vez por ronda finalizada.
- [ ] Al alcanzar tres puntos, el estado pasa a `MATCH_RESULT` y no inicia otra ronda.
- [ ] Un cliente no puede cambiar localmente el resultado autoritativo de la ronda.
- [ ] Una prueba automatizada o headless cubre al menos una transición válida y una inválida.

## Entregable de sesión
Crear un handoff en `docs/handoffs/` con archivos modificados, comandos ejecutados, pruebas, decisiones y pendientes.

## Prompt para la CLI

> Lee primero `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/specs/00-game-general.md`, `docs/specs/01-network-lan.md`, este archivo y el handoff más reciente. Implementa únicamente el núcleo de estado y ciclo de partida descrito aquí. No inventes reglas ni cambies contratos compartidos sin documentarlo. Usa GDScript compatible con Godot 4. Mantén al host como autoridad. Ejecuta las pruebas disponibles, revisa el diff, crea un handoff incremental y agrega una entrada al final de `AI_TRACE.md`. Si falta una decisión de balance, usa una constante explícita y regístrala como pendiente; no la ocultes.
