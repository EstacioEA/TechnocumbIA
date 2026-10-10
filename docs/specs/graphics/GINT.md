# GINT — Integración y verificación visual por relevos

- Responsables: Juan Diego Balanta y Edwar Estacio
- Turno: C, después de GJ01, GE01, GV01, GK01 y GM01.
- Estado: TODO.

## Objetivo

Revisar el resultado de las cinco áreas visuales en el mismo flujo ejecutable, detectar solapamientos y dejar evidencia visual reproducible para el equipo.

## Archivos permitidos

- `scenes/` y `scripts/ui/` únicamente para conectar componentes de presentación aprobados; cada cambio de integración se explica en el handoff.
- `tests/ui/`, `tests/qa/` para preview/matriz visual.
- `docs/specs/graphics/`, `docs/handoffs/`, `AI_TRACE.md`.

No cambiar autoridad, reglas, combate, movimiento, colisiones ni transporte LAN. No integrar automáticamente ramas sin revisar el diff y el handoff de su responsable.

## Secuencia de verificación

1. Abrir el proyecto y recorrer menú → host/unirse → lobby → partida → resultado.
2. Comprobar lobby vacío, seis peers, ready/no-ready, cliente, host, error de conexión y desconexión.
3. En partida revisar seis jugadores, equipos/roles/iconos, mapa, Papa, zonas objetivo, HUD, overlay de visión y feedback de acciones.
4. Mostrar ACTIVE, POT_COOKING, ESCAPE, ROUND_RESULT y MATCH_RESULT. Aclarar en la evidencia cuáles estados son runtime y cuáles pertenecen a un preview.
5. Repetir las comprobaciones de composición en 1280×720, 1600×900 y 1920×1080. Confirmar foco teclado, texto sin recorte y HUD sobre overlay.
6. Ejecutar pruebas automatizadas disponibles para escenas/componentes tocados. Separar resultado de pruebas automatizadas del resultado visual manual.

## Matriz — completar durante el relevo

| Caso | Resultado inicial | Evidencia |
|---|---|---|
| Menú y navegación teclado | BLOCKED | pendiente |
| Errores/validación de red visibles | BLOCKED | pendiente |
| Lobby 1/6, 6/6, ready/no-ready, host/cliente | BLOCKED | pendiente |
| Personajes/equipos/roles distinguibles | BLOCKED | pendiente |
| Mapa, bases, rutas, olla y barrera legibles | BLOCKED | pendiente |
| HUD y feedback de acciones sobre visión | BLOCKED | pendiente |
| Estados de resultado de ronda/partida | BLOCKED | pendiente |
| Layout 1280×720 | BLOCKED | pendiente |
| Layout 1600×900 | BLOCKED | pendiente |
| Layout 1920×1080 | BLOCKED | pendiente |

## Aceptación observable

- [ ] Flujo visual completo ejecutado o cada bloqueo tiene reproducción exacta.
- [ ] La matriz tiene PASS/FAIL/BLOCKED y evidencia por cada fila; no quedan filas sin estado.
- [ ] Capturas identifican versión/commit revisado y resolución, sin datos privados innecesarios.
- [ ] Defectos se anotan con prioridad, pasos y responsable; no se corrigen fuera de alcance sin spec.
- [ ] Se revisan los diffs y se deja handoff de relevo con pruebas automatizadas y manuales separadas.
- [ ] `AI_TRACE.md` recibe una entrada incremental; no hay commit automático.

