# Handoff — V06 Indicador de salida y recorrido de atacante

- **Integrante:** Valeria Piza
- **Rama:** `Valeria_Piza/escape-exit-indicator`
- **Base:** `origin/develop` en `fd50357`
- **Tarea:** V06 — Indicador de salida y recorrido de atacante

## Implementación

Se creó `EscapeExitIndicator` como componente exclusivamente visual en el
extremo izquierdo del mapa. Expone `set_escape_available(bool)` e
`is_escape_available()`, muestra etiqueta e icono además del color, y no crea
`CollisionObject2D`, `CollisionShape2D`, timers ni decisiones de autoridad.
Repetir el mismo estado no emite señales ni cambia la presentación.

La escena reusable es `scenes/map/escape_exit_indicator.tscn`; su posición
visual es independiente de `PapoiMap.ESCAPE_ZONE`. No se editaron
`scripts/map/papoi_map.gd`, coordenadas, zonas ni colisiones.

## Evidencia

| Comando | Resultado |
|---|---|
| `godot --headless --path . --script res://tests/map/escape_exit_indicator_test.gd` | `V06_ESCAPE_EXIT_INDICATOR_TEST: PASS` |
| `godot --headless --path . --script res://tests/player/v06_escape_route_test.gd` | `V06_ESCAPE_ROUTE_TEST: PASS` |
| `godot --headless --editor --path . --quit` | PASS |

La prueba de recorrido confirma las acciones WASD registradas y una secuencia
de checkpoints dentro de los corredores existentes desde un spawn atacante
hacia `POT_ZONE` y luego `ESCAPE_ZONE`. No modifica el mapa ni sustituye una
prueba manual interactiva de movimiento.
