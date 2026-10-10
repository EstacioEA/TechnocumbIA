# Handoff — GJ01 Cascarón del menú

- Fecha/hora: 2026-10-10 03:15 (America/Bogota)
- Integrante: Juan Diego Balanta
- Rama: `Juan_Balanta/gj01-menu-shell`
- Rama base: `develop` actualizado desde `origin/develop`
- Estado: BLOCKED — implementación creada; verificación visual pendiente.
- Tarea: GJ01 — título Papoi, acciones Host/Unirse/Salir, foco de teclado.
- Dependencias verificadas: ninguna; no depende de Edwar ni del Theme final.

## Cambios

- Archivos creados: `scenes/menu/main_menu.tscn`, `scripts/ui/menu/main_menu.gd`.
- Archivos modificados: `project.godot`, spec gráfico de Juan y `docs/specs/Juan_Balanta/TASKS.md`.
- Se establece el menú como escena inicial. Host/Unirse emiten señales UI y muestran que sus paneles se conectarán en GJ02/GJ03; Salir cierra la aplicación.
- El menú usa tokens G00 provisionales codificados en estilos locales; no requiere Theme de Edwar.
- Archivos fuera de alcance modificados: ninguno.

## Criterios de aceptación

- [x] Escena raíz con título Papoi y botones Host/Unirse/Salir implementada.
- [x] Host/Unirse emiten señales de interfaz sin cambiar estado de red.
- [x] Salir solicita cerrar el juego.
- [ ] Proyecto abre la escena sin errores y se revisa visualmente a 1280×720 — pendiente; no se ejecutó Godot en esta sesión.
- [ ] Foco de teclado visible confirmado en ejecución — pendiente de revisión visual.

## Pruebas y revisión

| Comando o procedimiento | Resultado | Evidencia |
|---|---|---|
| `git diff --check` | PASS | Sin errores de whitespace en diff rastreado |
| Ejecución Godot / captura de escena | BLOCKED | No ejecutada; queda pendiente de una solicitud explícita de verificación |

## Riesgos y siguiente paso

- Host/Unirse todavía no muestran sus paneles; eso pertenece a GJ02/GJ03. El mensaje temporal informa que la conexión se añadirá en las tareas siguientes.
- Antes de marcar GJ01 DONE, abrir Papoi, comprobar carga/foco/layout a 1280×720 y guardar una captura. Después seguir con GJ02 (crear partida), que no requiere trabajo de Edwar.

## Trazabilidad

Se agregó una entrada incremental a `AI_TRACE.md`; no se creó commit.
