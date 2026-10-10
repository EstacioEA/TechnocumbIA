# Handoff — TC01 Avatares con sprites

- **Integrante:** Valeria Piza
- **Rama:** `Valeria_Piza/avatar-sprites`
- **Tarea:** TC01 — Avatares con sprites
- **Base:** `origin/develop` en `d0a0f34`

## Resultado

`PlayerVisual` ahora muestra el primer cuadro del sheet correspondiente al rol:
Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas. El sprite se recorta
como atlas de 10 columnas por 4 filas y un shader descarta el patrón de
transparencia horneado en los sheets. Si el rol aún no está disponible, se
conserva la silueta procedural anterior como fallback.

El preview de seis jugadores asigna los seis roles. La integración de partida
lee `role` para defensores y `passive` para atacantes desde el snapshot
autoritativo y actualiza solo `PlayerVisual`; el `PlayerToken` de color deja de
ser la representación principal. Collider, input, cámara, autoridad, spawns y
transporte no fueron modificados.

## Procedencia

Los sheets usados son los assets proporcionados por el equipo en:

- `assets/characteres/papa/papa_sprites.jpeg`
- `assets/characteres/trolazo/trolazo_sprites.png`
- `assets/characteres/bestia/bestia_sprites.png`
- `assets/characteres/defensora/defensora_sprites.png`
- `assets/characteres/cazador/cazador_sprites.jpeg`
- `assets/characteres/porta_papa/porta_papa_sprites.png`

No se incorporaron assets externos.

## Verificación

| Comando | Resultado |
|---|---|
| `godot --headless --path . --script res://tests/ui/gv03_six_players_test.gd` | PASS — seis roles, seis sprites, equipos, marcador local y colliders |
| `godot --headless --path . --script res://tests/ui/gv02_orientation_test.gd` | PASS |
| `godot --headless --path . --script res://tests/qa/v03_player_collision_test.gd` | PASS |
| Diagnósticos VS Code de `player_visual.gd` | Sin diagnósticos |

