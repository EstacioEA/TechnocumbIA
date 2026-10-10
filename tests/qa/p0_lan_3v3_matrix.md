# Matriz P0 — integración LAN 3v3

Rama de ejecución: `Krystal_Giraldo/map-pot-hud`

## Preparación reproducible

1. Abrir el proyecto en Godot 4 una vez exista `project.godot` y la escena de integración.
2. Instanciar `scenes/map/papoi_map.tscn`, `scenes/objectives/papoi_objective_flow.tscn` y `scenes/ui/papoi_hud.tscn`.
3. Conectar el HUD al flujo con `bind_objective_flow`.
4. Ejecutar el host y seis clientes de la integración LAN.
5. Registrar el resultado real en la columna **Resultado**; no convertir bloqueos de entorno en PASS.

## Casos P0

| ID | Caso | Pasos / resultado esperado | Resultado |
|---|---|---|---|
| P0-01 | Lobby 3v3 | Conectar seis clientes; host inicia con dos equipos de tres y roles visibles. | BLOCKED — no existe escena de lobby/red en este alcance. |
| P0-02 | Carga de mapa | Instanciar `PapoiMap`; no hay errores; aparecen límites, bases, rutas, sala y marcadores. | BLOCKED — Godot 4 no está instalado en el entorno. |
| P0-03 | Colisiones y límites | Mover un `CharacterBody2D` contra los cuatro límites y la entrada cerrada; no atraviesa. | BLOCKED — requiere ejecución Godot y personaje de integración. |
| P0-04 | Spawns | Consultar `get_spawn_points`; hay tres posiciones por equipo, Papa y Bestia. | PASS — verificación estática de constantes y método. |
| P0-05 | Papa válida en olla | Host marca Papa válida dentro; el flujo acepta la detección y rechaza una transición no autorizada. | PASS — verificación estática de guardas de autoridad. |
| P0-06 | Inicio y HUD de cocción | Host inicia; fase `POT_COOKING`, host avanza el reloj mediante `advance_host_clock`, temporizador visible y entrada Bestia desbloqueable por host. | BLOCKED — requiere ejecución Godot 4. |
| P0-07 | Rescate de Bestia | Durante `POT_COOKING`, host rescata; cocción se cancela y objetivo vuelve a captura. | PASS — verificación estática de transición y guardas. |
| P0-08 | Escape | Al finalizar cocción, fase `ESCAPE`; solo host puede marcar escape en base atacante. | PASS — verificación estática de transición y guardas. |
| P0-09 | HUD de partida | Mostrar fase, ronda, tiempo, marcador, vidas, rol, pasiva, cooldowns y objetivo sin logs. | PASS — verificación estática de nodos y métodos de presentación. |
| P0-10 | Resultado de ronda/partida | Integración muestra paneles de resultado sin inventar condición de victoria. | BLOCKED — resultados autoritativos y red pertenecen a otros módulos. |
| P0-11 | Derrota por tiempo/vidas | Host resuelve según estado compartido; UI muestra el resultado. | BLOCKED — no implementado aquí por restricción de autoridad y alcance. |
| P0-12 | Desconexión | Desconectar cliente; host cancela o invalida explícitamente, sin continuar silenciosamente. | BLOCKED — red pertenece a `01-network-lan.md`. |

## Defectos y prioridades

- **P0 bloqueante:** Falta `project.godot`, escena de integración y runtime Godot en `main`; no se puede realizar una prueba headless real.
- **P0 de integración:** El flujo necesita que el módulo autoritativo del host conecte `set_papa_in_pot`, `start_cooking`, `rescue_by_beast`, `apply_cooking_result` y `mark_escape_reached`.
- **P1:** La dirección exacta del arte oficial del mapa y su licencia no están confirmadas; el mapa incluido aquí es procedural y de referencia.
