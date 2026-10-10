# Spec gráfico — Juan Diego Balanta

## Turno A — Juan Diego Balanta

Juan puede completar GJ01–GJ05 sin esperar el Theme ni una revisión de Edwar. Usará directamente los tokens provisionales ya descritos en `docs/specs/graphics/VISUAL_DIRECTION.md`; la adopción posterior de `papoi_theme.tres` es una mejora de integración, no una dependencia. Las tareas de Juan no modifican archivos que GE01–GE05 poseen.

### GJ01 — Cascarón del menú
- Estado: BLOCKED — implementación creada; falta abrir y verificar visualmente la escena.
- Depende de: ninguna.
- Archivos: nuevos `scenes/menu/main_menu.tscn`, `scripts/ui/menu/main_menu.gd`; `project.godot` solo para establecer esta escena como entrada.
- Aceptación: ejecutar el proyecto abre el menú con título Papoi y acciones Host, Unirse y Salir; disposición y foco de teclado son visibles a 1280×720; las acciones Host/Unirse emiten señales de UI sin mutar la red.

### GJ02 — Panel de crear partida
- Estado: TODO; depende de: GJ01.
- Archivos: nuevos `scenes/menu/host_panel.tscn`, `scripts/ui/menu/host_panel.gd`.
- Aceptación: presenta puerto editable con valor inicial visible, botón Crear y estados disponible/validación/error; muestra errores en pantalla. No cambia ENet ni protocolo.

### GJ03 — Panel de conexión por IP
- Estado: TODO; depende de: GJ01.
- Archivos: nuevos `scenes/menu/join_panel.tscn`, `scripts/ui/menu/join_panel.gd`.
- Aceptación: IP y puerto editables; IP/puerto inválidos se señalan antes de conectar; estados conectando/rechazo/desconexión tienen texto legible. Usa las APIs existentes de red.

### GJ04 — Presentación de lobby
- Estado: TODO; depende de: GJ02 y GJ03 por navegación; puede construirse en archivo/escena propia antes de integrar.
- Archivos: `scenes/lobby/`, `scripts/ui/lobby/`, `tests/ui/`.
- Aceptación: seis slots visibles; nombre/ID, host y ready diferenciados; estado vacío, parcial, lleno y desconectado reconocibles; cliente ve inicio deshabilitado y host ve el motivo si no puede iniciar. No altera `NetworkManager`.

### GJ05 — Navegación y revisión visual de Turno A
- Estado: TODO; depende de: GJ01–GJ04.
- Archivos: solo escenas/scripts UI de Juan, `tests/ui/`, handoff y `AI_TRACE.md`.
- Aceptación: flujo menú→host/unirse→lobby se recorre por teclado y mouse; capturas a 1280×720 y 1600×900 sin texto cortado; preview queda rotulado; handoff enumera estados mostrados y defectos.

### Reglas y prompt operativo
No esperar a Edwar para cerrar GJ01–GJ05. Usar colores/estilos provisionales documentados y dejar el punto exacto de Theme para GINT. Leer contexto, orquestador, política de ramas, plan gráfico, contrato visual y spec UI; verificar rama; limitar cambios a archivos indicados; probar escenas realmente ejecutables; actualizar `AI_TRACE.md` y crear handoff sin afirmar pruebas no ejecutadas. No cambiar red, autoridad, combate ni estado de juego.
