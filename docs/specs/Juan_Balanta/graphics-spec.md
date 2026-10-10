# Spec gráfico — Juan Diego Balanta

## Turno A — Juan Diego Balanta

Juan puede completar GJ01–GJ05 sin esperar el Theme ni una revisión de Edwar. Usará directamente los tokens provisionales ya descritos en `docs/specs/graphics/VISUAL_DIRECTION.md`; la adopción posterior de `papoi_theme.tres` es una mejora de integración, no una dependencia. Las tareas de Juan no modifican archivos que GE01–GE05 poseen.

### GJ01 — Cascarón del menú
- Estado: DONE — menú y controles revisados a 1280×720 y 1600×900; evidencia en `docs/handoffs/evidence/gj05/`.
- Depende de: ninguna.
- Archivos: nuevos `scenes/menu/main_menu.tscn`, `scripts/ui/menu/main_menu.gd`; `project.godot` solo para establecer esta escena como entrada.
- Aceptación: ejecutar el proyecto abre el menú con título Papoi y acciones Host, Unirse y Salir; disposición y foco de teclado son visibles a 1280×720; las acciones Host/Unirse emiten señales de UI sin mutar la red.

### GJ02 — Panel de crear partida
- Estado: DONE — panel validado visualmente y flujo host integrado en GJ05.
- Depende del artefacto GJ01, cuya revisión visual quedó cubierta a 1280×720 y 1600×900 en GJ05; GJ02 es un panel aislado.
- Archivos: nuevos `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd`; conexión de vista en `scripts/ui/menu/main_menu.gd`.
- Criterios del corte aislado GJ02: Host abre el panel; puerto inicial 2456 editable; Crear valida rango 1–65535 y da error inline; puerto válido emite `create_requested(port)`; Volver regresa al menú. En ese corte no se iniciaba ENet; GJ05 integró después la creación real de sesión LAN.

### GJ03 — Panel de conexión por IP
- Estado: DONE — validación visual y conexión real de cliente integradas en GJ05.
- Depende del artefacto GJ01, cuya revisión visual quedó cubierta a 1280×720 y 1600×900 en GJ05; GJ03 es un panel aislado.
- Archivos: nuevos `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd`; conexión de vista en `scripts/ui/menu/main_menu.gd`.
- Aceptación del corte aislado GJ03: IP/puerto editables y validados inline; entrada válida emite `join_requested(address, port)`; volver regresa al menú. En ese corte el panel comunicaba que el transporte aún no estaba integrado; GJ05 integró después el flujo real de host/join con la sesión LAN.

### GJ04 — Presentación de lobby
- Estado: DONE — preview aislado implementado y comprobado; su integración de navegación queda para GJ05.
- Dependencias: GJ02/GJ03 para navegar desde el menú, no para construir/probar esta escena independiente.
- Archivos: `scripts/ui/lobby/`, `tests/ui/`; ajuste del test de interfaz en `tests/network/ready_start_test.gd` para reflejar que cliente ve inicio deshabilitado.
- Aceptación: seis slots fijos; nombre/ID, host/cliente y ready/no-ready diferenciados; estado vacío, parcial, lleno y desconectado reconocibles; cliente ve inicio deshabilitado y host el motivo cuando no puede iniciar. NetworkManager/protocolo no se modifica.
- Evidencia: prueba UI y `run_lobby_slots_test.ps1` PASS. El primer `run_ready_start_test.ps1` falló en teardown tras alcanzar marcadores de inicio; Edwar documentó una corrección y tres PASS en el handoff 10:23. La reejecución 10:41 llegó a `GAME_SESSION_READY` en seis procesos pero falló al comprobar el código vacío de salida de `client1`; la discrepancia actual se sigue en GINT.

### GJ05 — Navegación y revisión visual de Turno A
- Estado: DONE — integración host/join revisada en dos resoluciones, con pruebas visuales y LAN multiinstancia PASS. Handoff: `docs/handoffs/2026-10-10-0358-GJ05-menu-lobby-integration.md`.
- Archivos: scripts de menú/lobby, `tests/ui/`, capturas en `docs/handoffs/evidence/`, handoff y `AI_TRACE.md`.
- Aceptación: menú→host/unirse→lobby usa la sesión LAN existente; errores/rechazo se ven; controles son enfocables por teclado y activables con mouse; capturas verificadas a 1280×720 y 1600×900 sin texto cortado; preview rotulado; handoff enumera cobertura, pruebas y defectos. No se modifica autoridad ni protocolo.
- Evidencia: 16 capturas disponibles en `docs/handoffs/evidence/gj05/{1280x720,1600x900}/`; `gj05_visual_capture_test.gd` genera 12 (seis vistas por resolución), y `run_gj05_menu_lan_test.ps1` PASS. Pruebas de transporte y slots PASS.

### Reglas y prompt operativo
No esperar a Edwar para cerrar GJ01–GJ05. Usar colores/estilos provisionales documentados y dejar el punto exacto de Theme para GINT. Leer contexto, orquestador, política de ramas, plan gráfico, contrato visual y spec UI; verificar rama; limitar cambios a archivos indicados; probar escenas realmente ejecutables; actualizar `AI_TRACE.md` y crear handoff sin afirmar pruebas no ejecutadas. No cambiar red, autoridad, combate ni estado de juego.
