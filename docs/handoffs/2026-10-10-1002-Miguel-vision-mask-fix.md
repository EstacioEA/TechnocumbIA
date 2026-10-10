# Handoff — Corrección de máscara de visión

- Fecha/hora: 2026-10-10 10:02 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `Miguel_Pabon/fix-vision-mask`.
- Rama base: `Miguel_Pabon/role-differences-preview`.
- Estado: DONE.
- Tarea: invertir la máscara del campo de visión local.

## Problema

El shader de `VisionOverlay` multiplicaba el alpha del overlay dentro del radio visible. El resultado era un círculo oscuro alrededor del jugador y el resto del mapa visible.

## Corrección

En `scenes/player/player.tscn`, la máscara ahora usa `outside_visibility`:

- Dentro del radio: alpha del overlay cercano a `0`, mapa visible.
- Fuera del radio: alpha del overlay cercano a `overlay_color.a`, mapa oscurecido.
- Se conserva un borde suave de `0.025`.

## Pruebas

| Verificación | Resultado |
|---|---|
| `tests/qa/v04_camera_vision_test.gd` | PASS — shader verifica máscara exterior |
| `tests/qa/gk04_contrast_evidence_test.gd` | PASS |
| `git diff --check` | PASS |

## Prueba visual manual

Desde PowerShell:

```powershell
$godot = "C:\Users\Asus\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
& $godot --path "C:\Users\Asus\Desktop\PERSONAL\GAME\TechnocumbIA" --editor
```

En Godot abre `scenes/map/papoi_map_gk04_contrast_preview.tscn` y ejecuta con F6. Activa la visión con `V`. El círculo alrededor del jugador debe mostrar el mapa normalmente y las zonas fuera del círculo deben verse negras/oscuras.

## Alcance

No se modificaron combate, roles, red, HUD ni autoridad de la partida. No se creó commit automático.
