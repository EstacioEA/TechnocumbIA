# V01 — Prueba de la base del jugador

## Escena

Abrir `tests/player/player_base_test.tscn` en Godot 4. La escena instancia dos
veces `scenes/player/player_base.tscn` y no requiere red, lobby ni estado de
partida.

## Verificaciones

1. Confirmar que la escena carga sin errores.
2. Confirmar que existen `PlayerOne` y `PlayerTwo`.
3. Confirmar que ambos nodos son instancias de `PapoiPlayerBase`.
4. Confirmar que cada instancia contiene un `CollisionShape2D` circular.
5. Confirmar que no se requiere `NetworkManager`, `GameState` ni entrada de
   teclado para cargar la escena.
