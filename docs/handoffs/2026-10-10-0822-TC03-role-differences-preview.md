# Handoff — Preview interactivo TC03

- Fecha/hora: 2026-10-10 08:22 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `Miguel_Pabon/role-differences-preview`.
- Rama base: `Miguel_Pabon/role-differences-verification`.
- Estado: DONE.
- Tarea: crear un preview manual para probar las diferencias funcionales de roles y pasivas.

## Uso

Desde la raíz del proyecto:

```powershell
$godot = "C:\Users\Asus\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
& $godot --path . --editor
```

En Godot, abre `scenes/ui/role_differences_preview.tscn` y ejecútala con F6.

El preview contiene seis pestañas:

1. Roles: asignación host y rechazo de asignación cliente.
2. Papa: captura, sprint, soltar y golpe al portador.
3. Vidas: golpe sin Papa, respawn, golpe con Papa y reinicio de ronda.
4. Bestia: aparición a 30 s, ataques, cooldown y acceso a olla.
5. Pasivas: trampa Trolazzo, efectos de Tanque/Cazador/Porta Papas y enfurecimiento.
6. Autoridad: intentos de mutación desde cliente, todos deben rechazarse.

El texto superior aclara que es una simulación local y no una partida LAN.

## Pruebas

| Verificación | Resultado |
|---|---|
| `Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/ui/role_differences_preview_test.gd` | PASS — seis pestañas y acciones funcionales |
| `git diff --check` | PASS |

## Alcance y limitaciones

- El preview usa las clases reales de roles, Papa, vidas, Bestia y pasivas con autoridad de host.
- No modifica `GameState`, red ni la escena principal.
- Es una herramienta de validación manual; no reemplaza una partida LAN de seis clientes.
