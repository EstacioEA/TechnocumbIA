# Prueba manual de movimiento, cámara y visión

## Escena

Abrir `tests/player/player_test.tscn` desde un proyecto Godot 4 que incluya
esta rama. La escena contiene dos instancias de `PapoiPlayerController`; solo
`PlayerOne` acepta entrada local.

## Controles

- `W`: mover hacia arriba.
- `A`: mover hacia la izquierda.
- `S`: mover hacia abajo.
- `D`: mover hacia la derecha.

## Verificaciones

1. Mantener una tecla WASD y confirmar que `PlayerOne` se desplaza.
2. Empujar `PlayerOne` contra cada pared y confirmar que no la atraviesa.
3. Confirmar que la cámara sigue a `PlayerOne` y respeta el rectángulo de límites.
4. Confirmar que el área circular alrededor del jugador queda visible y el resto
   se oscurece.
5. Añadir un `CanvasLayer` de HUD con `layer > 20` y confirmar que queda sobre
   el overlay.
6. Confirmar que `PlayerTwo` puede coexistir sin errores y no acepta WASD.

## Red

`movement_intent(direction)` emite la intención local. El host debe conectar esa
señal a su validador y aplicar la posición autoritativa con
`apply_authoritative_velocity`; el controlador no expone una RPC que acepte
posiciones enviadas por el cliente.
