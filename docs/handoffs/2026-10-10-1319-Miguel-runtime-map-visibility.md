# Handoff — mapa visible durante el arranque real de partida

- Fecha/hora: 2026-10-10 13:19 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `develop`.
- Estado: DONE para la integración local.

## Problema reportado

La preview `res://scenes/map/papoi_map_tc02_playable_preview.tscn` mostraba el
mapa, pero al iniciar una partida mediante `F5`, crear seis jugadores y activar
las cámaras, la vista visual del mapa no aparecía aunque sí estaban presentes
las colisiones, Papa y los demás elementos de gameplay.

## Corrección

- El fondo usa `MapBackground`, un `Sprite2D` explícito con `Mapa Base.jpeg`.
- La capa visual del mapa ahora usa `z_index = -10` y el sprite usa la capa de
  mundo relativa `z_index = 0`, evitando depender de un orden implícito de dibujo.
- El mapa conserva sus dimensiones de juego de `1280×720`, centrado en `(640, 360)`.
- Se añadió una prueba que instancia `PapoiGameSession`, activa el modo local,
  inicia un roster de seis jugadores y verifica el fondo después de crear los
  nodos de jugador y sus cámaras.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/game/runtime_map_visibility_test.gd` | PASS |
| `tests/qa/gk01_map_visuals_test.gd` | PASS |
| `tests/game/game_integration_test.gd` | PASS |
| `git diff --check` | PASS |

## Prueba manual

1. Ejecutar el proyecto con `F5`.
2. Crear una partida como host.
3. Completar el lobby con seis jugadores listos.
4. Iniciar la partida.
5. Confirmar que el fondo de `Mapa Base.jpeg` aparece detrás de los jugadores,
   Papa, la olla y el HUD.

La prueba automatizada no sustituye la confirmación visual en seis procesos LAN.
El warning de mayúsculas en el recurso visual de Bestia es preexistente y no
bloquea el fondo del mapa.

No se creó commit automático.
