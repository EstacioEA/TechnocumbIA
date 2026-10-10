# Handoff — V05 Prueba de instancias

- **Fecha/hora:** 2026-10-10 01:56 UTC-05
- **Integrante:** Valeria Piza
- **Rama:** `Valeria_Piza/player-smoke-test`
- **Rama base:** `develop` actualizada
- **Estado:** DONE
- **Tarea:** V05 — Prueba de instancias
- **Dependencias:** V03 y V04 verificadas como `DONE` en `develop`

## Validaciones

- Se instancian dos jugadores desde la escena reutilizable sin errores.
- El jugador local procesa WASD y emite `movement_intent`.
- El jugador remoto no se mueve por el input local.
- El jugador remoto sí acepta velocidad aplicada por el host mediante
  `apply_authoritative_velocity`.

## Prueba

| Comando | Resultado |
|---|---|
| `godot --headless --path . --script res://tests/player/player_smoke_test.gd` | PASS |

## Archivos

- `tests/player/player_smoke_test.gd`
- `docs/specs/Valeria_Piza/TASKS.md`

## Estado de integración

La escena no crea RPCs de posición en el cliente. La intención local se expone
por señal para que el host la valide y aplique el movimiento autoritativo.
