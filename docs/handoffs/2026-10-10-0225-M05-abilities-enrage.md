# Handoff — M05 Trampa, pasivas y enfurecimiento

- Fecha/hora: 2026-10-10 02:25 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `Miguel_Pabon/abilities-enrage`.
- Rama base: `develop`.
- Estado: DONE.
- Spec: `docs/specs/Miguel_Pabon/TASKS.md`.
- Tarea: M05 — trampa, pasivas y enfurecimiento.
- Dependencias verificadas: M03 DONE; M04 DONE; K03 DONE.

## Cambios

- Archivos creados: `scripts/abilities/abilities_enrage_state.gd`, `tests/combat/test_abilities_enrage_state.gd`, este handoff.
- Archivos modificados: `docs/specs/Miguel_Pabon/TASKS.md`, `scripts/objectives/papoi_cooking_escape.gd`, `AI_TRACE.md`.
- Archivos fuera de alcance modificados: ninguno.

## Criterios de aceptación

- [x] Trampa MVP de Trolazzo con cooldown host-authoritativo de 8 segundos y duración temporal de 5 segundos.
- [x] Tanque reduce el multiplicador de daño de trampa a 0.5.
- [x] Cazador obtiene multiplicador 1.25 contra Bestia.
- [x] Porta Papas expone reducción de sprint de 2 segundos.
- [x] Cocción completada activa enfurecimiento de Bestia.
- [x] Enfurecimiento aplica boost de velocidad 1.25x y reduce cooldowns al 50%.
- [x] Cooldowns se limitan a valores no negativos y mutaciones se rechazan fuera del host.

## Pruebas

| Comando | Resultado | Evidencia |
|---|---|---|
| `Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/combat/test_abilities_enrage_state.gd` | PASS | `abilities_enrage_state_test: PASS`, código 0 |
| `Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/combat/test_beast_access_state.gd` | PASS | Regresión de aparición, ataques y acceso a olla |
| `Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/qa/k03_cooking_escape_test.gd` | PASS | Regresión de cocción, rescate y escape |
| `git diff --check` | PASS | Sin errores de whitespace |

## Decisiones y constantes

- Cooldown temporal de trampa: 8 segundos; duración temporal: 5 segundos.
- Tanque: multiplicador de daño de trampa 0.5.
- Cazador: multiplicador contra Bestia 1.25.
- Porta Papas: reducción por sprint 2 segundos.
- Enfurecimiento: velocidad 1.25x y cooldowns al 50%.
- El evento `request_cooking_completed()` debe conectarse a `PapoiCookingEscape.cooking_completed` desde el host.

## Bloqueos y riesgos

- La conexión de la señal de cocción con este módulo queda para la integración del host; el módulo no escucha señales por sí mismo para evitar duplicar autoridad.
- Se ajustaron las referencias tipadas del coordinador K03 a `RefCounted` para que el test headless cargue de forma estable en Godot 4.7.2.
- La aplicación física del multiplicador de daño debe consumir estos getters en el sistema de impactos.
- Los valores temporales de balance requieren revisión del equipo.

## Siguiente tarea recomendada

- Revisión de integración M01-M05 con GameState, K03 y HUD/QA.

## Trazabilidad

- Entrada agregada a `AI_TRACE.md`: sí.
