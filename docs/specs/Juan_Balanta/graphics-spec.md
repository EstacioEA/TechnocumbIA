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
- Depende del artefacto de escena GJ01 (su revisión visual queda pendiente, pero GJ02 es un panel aislado).
- Archivos: nuevos `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd`; conexión de vista en `scripts/ui/menu/main_menu.gd`.
- Aceptación: Host abre el panel; puerto inicial 2456 editable; Crear valida rango 1–65535 y da error inline; puerto válido emite `create_requested(port)` y comunica claramente que esta subtarea aún no inicia ENet; Volver regresa al menú. No cambia ENet ni protocolo.

### GJ03 — Panel de conexión por IP
- Estado: DONE — validación visual y conexión real de cliente integradas en GJ05.
- Depende de: artefacto de escena GJ01 (su revisión visual queda pendiente; GJ03 es un panel aislado).
- Archivos: nuevos `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd`; conexión de vista en `scripts/ui/menu/main_menu.gd`.
- Aceptación: IP y puerto editables; IP/puerto inválidos se señalan antes de emitir; entrada válida emite `join_requested(address, port)`; volver regresa al menú. El panel comunica que transporte/estados de conexión aún no están integrados. No llama ni modifica ENet/NetworkManager; GJ05 conectará la intención a la sesión cuando integre navegación.

### GJ04 — Presentación de lobby
- Estado: DONE — preview aislado implementado y comprobado; su integración de navegación queda para GJ05.
- Dependencias: GJ02/GJ03 para navegar desde el menú, no para construir/probar esta escena independiente.
- Archivos: `scripts/ui/lobby/`, `tests/ui/`; ajuste del test de interfaz en `tests/network/ready_start_test.gd` para reflejar que cliente ve inicio deshabilitado.
- Aceptación: seis slots fijos; nombre/ID, host/cliente y ready/no-ready diferenciados; estado vacío, parcial, lleno y desconectado reconocibles; cliente ve inicio deshabilitado y host el motivo cuando no puede iniciar. NetworkManager/protocolo no se modifica.
- Evidencia: prueba UI y pruebas LAN de slots PASS. Ready/start llega a sus marcadores de aceptación, pero el runner termina FAIL por errores de multiplayer al apagar clientes después del inicio, localizados en `scripts/game/papoi_game_session.gd` (fuera de alcance y sin cambios en esta tarea); queda para integración/QA.

### GJ05 — Navegación y revisión visual de Turno A
- Estado: DONE — integración host/join revisada en dos resoluciones, con pruebas visuales y LAN multiinstancia PASS. Handoff: `docs/handoffs/2026-10-10-0358-GJ05-menu-lobby-integration.md`.
- Archivos: scripts de menú/lobby, `tests/ui/`, capturas en `docs/handoffs/evidence/`, handoff y `AI_TRACE.md`.
- Aceptación: menú→host/unirse→lobby usa la sesión LAN existente; errores/rechazo se ven; controles son enfocables por teclado y activables con mouse; capturas verificadas a 1280×720 y 1600×900 sin texto cortado; preview rotulado; handoff enumera cobertura, pruebas y defectos. No se modifica autoridad ni protocolo.
- Evidencia: 16 capturas disponibles en `docs/handoffs/evidence/gj05/{1280x720,1600x900}/`; `gj05_visual_capture_test.gd` genera 12 (seis vistas por resolución), y `run_gj05_menu_lan_test.ps1` PASS. Pruebas de transporte y slots PASS.

### Reglas y prompt operativo
No esperar a Edwar para cerrar GJ01–GJ05. Usar colores/estilos provisionales documentados y dejar el punto exacto de Theme para GINT. Leer contexto, orquestador, política de ramas, plan gráfico, contrato visual y spec UI; verificar rama; limitar cambios a archivos indicados; probar escenas realmente ejecutables; actualizar `AI_TRACE.md` y crear handoff sin afirmar pruebas no ejecutadas. No cambiar red, autoridad, combate ni estado de juego.
