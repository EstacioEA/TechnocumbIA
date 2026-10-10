# Handoff — versión integrada del juego y corrección de mapa visible

- Fecha/hora: 2026-10-10 13:05 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `develop`.
- Estado: DONE para integración local y pruebas headless.

## Problema

Al iniciar una partida se creaban las dimensiones físicas, límites y colisiones de
`PapoiMap`, pero la imagen visual dependía únicamente del dibujo de `_draw()` del
script `PapoiMapVisuals`. La escena integrada no tenía un nodo explícito que
garantizara la presentación del fondo del mapa.

## Corrección

- `PapoiMapVisuals` ahora contiene un `Sprite2D` llamado `MapBackground`.
- El sprite usa `assets/maps/Mapa Base.jpeg`.
- La textura de 1600×900 se centra en `(640, 360)` y se escala a 1280×720.
- Se conserva la capa visual detrás de jugadores, olla, salida, overlay de visión y HUD.
- Se eliminó el dibujo duplicado de la textura desde `_draw()`.
- La escena integrada mantiene el mapa, HUD, jugadores, cámara, indicador de salida,
  marcador de Papa y sistemas de captura, vidas, Bestia, pasivas, cocción y escape.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/game/integrated_game_visual_test.gd` | PASS |
| `tests/qa/gk01_map_visuals_test.gd` | PASS |
| `tests/game/game_integration_test.gd` | PASS |
| Carga del proyecto con Godot 4.7.2 | PASS |
| `git diff --check` | PASS |

## Limitaciones

- La validación realizada es local/headless; la partida LAN con seis procesos debe
  seguir validándose con el runner J05.
- Godot actualizó cachés `.godot` y archivos de importación locales al cargar el
  proyecto; no forman parte del cambio funcional.
- Godot muestra un warning preexistente de diferencia de mayúsculas en la ruta del
  sprite de Bestia; no bloquea esta corrección del mapa, pero debe corregirse antes
  de exportar a plataformas sensibles a mayúsculas.

No se creó commit automático.
