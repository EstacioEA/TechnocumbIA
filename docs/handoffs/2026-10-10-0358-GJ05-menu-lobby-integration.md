# Handoff GJ05 — menú, LAN y lobby

- Fecha: 2026-10-10 03:58 (America/Bogota)
- Responsable: Juan Diego Balanta
- Rama: `Juan_Balanta/gj05-menu-lobby-integration`
- Base: `origin/develop` en `d20c174` (GJ04)
- Estado: DONE; cambios sin commit.

## Alcance implementado

- El menú abre Host o Unirse y transiciona al lobby tras aceptar la intención.
- Host crea sesión ENet; cliente conecta a IP/puerto mediante `NetworkManager`.
- El lobby refleja roster y estado de conexión, informa errores/rechazos, deja volver al menú y evita mostrar el inicio al host como disponible antes de cumplir condiciones.
- Paneles comunican estados de creación/conexión en lugar de mensajes de transporte pendiente.
- No se cambian autoridad, protocolo, combate ni estado de juego.

## Archivos

- `scripts/ui/menu/main_menu.gd`
- `scripts/ui/menu/host_panel.gd`
- `scripts/ui/menu/join_panel.gd`
- `scripts/ui/lobby/lobby.gd`
- `tests/ui/gj05_visual_capture_test.gd`
- `tests/ui/gj05_menu_lan_test.gd`
- `tests/ui/run_gj05_menu_lan_test.ps1`
- `docs/handoffs/evidence/gj05/` (16 capturas disponibles; la prueba automatizada genera 12: menú, host, join, estado de conexión, rechazo preview y lobby host parcial, en 1280×720 y 1600×900)
- `docs/specs/Juan_Balanta/graphics-spec.md`
- `docs/specs/Juan_Balanta/TASKS.md`
- `AI_TRACE.md`

## Pruebas y resultados

- Godot 4.7.2 `tests/ui/gj05_visual_capture_test.gd`: PASS; genera 12 capturas en ambas resoluciones, comprueba foco, entrada de mouse, navegación, validación de IP/puerto, estado de host y mensajes visibles. Las imágenes se revisaron visualmente; no se observa texto cortado.
- `tests/ui/run_gj05_menu_lan_test.ps1`: PASS; dos procesos navegan desde menú, host y cliente se conectan por localhost y observan roster de dos (`GJ05_MENU_LAN_PASS`).
- `tests/ui/lobby_presentation_test.gd`: PASS.
- `tests/network/run_lan_transport_test.ps1`: PASS.
- `tests/network/run_lobby_slots_test.ps1`: PASS; límite de seis, rechazo del séptimo y roster actualizado tras desconexión.
- `git diff --check`: PASS antes de actualizar documentación.

## Pendientes y límites conocidos

- El rechazo que aparece en la captura visual se activa como preview de UI; el rechazo real del séptimo participante está cubierto por la prueba multiinstancia de slots.
- La prueba ready/start ejecutada durante GJ04 llegó a sus marcadores de aceptación pero el runner falló durante el apagado de clientes, con errores en `scripts/game/papoi_game_session.gd`. Ese defecto de cierre queda para seguimiento y no se modificó aquí.
- No se probó entre equipos físicos distintos; la prueba end-to-end usa localhost.
- GJ01–GJ05 quedan DONE. GINT sigue TODO hasta que sus dependencias de los demás integrantes estén listas.

## Continuación

Revisar este diff y las capturas; luego crear el commit desde esta rama según el flujo oficial. Mensaje sugerido: `feat(ui): integrate LAN menu and lobby flow`.
