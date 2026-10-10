# Planeación gráfica de Papoi

## Objetivo
Completar una capa visual coherente y demostrable para menú, lobby, mapa, personajes, HUD, feedback de acciones y resultados. Los sistemas de juego conservan su autoridad: la presentación lee sus estados y no inventa reglas.

## Relevos de trabajo

### Turno A — Juan + Edwar (ahora)
1. Los tokens provisionales G00 ya están escritos y pueden usarse desde ahora. Juan puede completar GJ01–GJ05 sin esperar Theme, código o revisión de Edwar.
2. Juan trabaja en menú/lobby; Edwar, en paralelo, en Theme/HUD/resultados con archivos separados.
3. La revisión de Juan al Theme es útil, pero no bloquea las tareas de Juan. La adopción del Theme refinado ocurre en GINT.
4. Cada cual deja handoff, decisiones, capturas y pendientes antes del relevo.

### Turno B — Valeria + Krystal + Miguel (cuando se incorporen)
Cada persona toma su spec en una rama propia después de leer el handoff A y G00: Valeria hace personajes; Krystal, mapa; Miguel, roles y feedback. Los archivos están separados para reducir conflictos. Si requieren tocar una escena compartida, primero acuerdan la interfaz y lo anotan en el handoff.

### Turno C — Juan + Edwar (cuando regresen)
Juan recorre menú → lobby → partida; Edwar revisa HUD y resultados. Juntos ejecutan GINT, integran las ramas revisando los diffs y dejan una matriz visual respaldada por capturas.

## Tareas y dependencias

| ID | Responsable | Entrega revisable | Depende de |
|---|---|---|---|
| GJ01–GJ03 | Juan | Cascarón, host y conexión por IP | Ninguna; GJ02/GJ03 requieren GJ01 |
| GJ04–GJ05 | Juan | Lobby, navegación y evidencia Turno A | GJ02/GJ03; GJ05 requiere GJ01–GJ04 |
| GE01–GE06 | Edwar | Theme, HUD, fases, rol/cooldown, resultados y preview | Secuencia interna GE01→GE02→GE03/GE04; GE05 depende GE01; GE06 requiere conjunto |
| GV01–GV03 | Valeria | Siluetas, orientación/marca local y preview seis jugadores | GV01→GV02→GV03 |
| GK01–GK04 | Krystal | Rutas, bases/spawns, olla/barrera y legibilidad | GK01 y GK02 en paralelo; GK03 independiente; GK04 tras conjunto |
| GM01–GM04 | Miguel | Roles, cooldown, estados Papa y preview de feedback | GM01→GM02→GM04; GM03 puede ir en paralelo |
| GINT01–GINT03 | Juan + Edwar | Ensamblaje, matriz visual y cierre de relevo | Entregas de Juan, Edwar, Valeria, Krystal y Miguel |

## Reglas comunes

- G00 escrito en `VISUAL_DIRECTION.md` es baseline suficiente para todas las personas. El Theme es una mejora de implementación de Edwar, no una dependencia para comenzar el trabajo visual de Juan.

- Base de diseño 1280×720; revisar también 1600×900 y 1920×1080.
- Los estados importantes se distinguen con texto/icono/forma además de color. Overlay de visión no cubre HUD ni alertas.
- Los datos simulados se etiquetan PREVIEW y no se conectan al flujo real. Runtime usa datos/eventos existentes.
- No incorporar arte externo de licencia o procedencia desconocida. Usar placeholders originales si falta arte aprobado.
- Cada entrega presenta capturas o pasos reproducibles y marca cada criterio PASS/FAIL/BLOCKED. Agrega entrada incremental a `AI_TRACE.md` y handoff; no atribuye pruebas no ejecutadas.
- El alcance es visual. No cambia autoridad, reglas de juego, colisiones ni transporte LAN.

## Hecho cuando

1. Las seis áreas gráficas tienen evidencia.
2. Se entiende el estado de menú, lobby, partida y resultados sin leer logs.
3. Jugadores, equipos, roles y Papa se distinguen con visión encendida y apagada.
4. No hay texto tapado/cortado en las tres resoluciones de referencia.
5. GINT enlaza la matriz visual a capturas y anota defectos pendientes.

## Specs

- [G00 — Contrato visual](VISUAL_DIRECTION.md)
- [Juan — Menú y lobby](../Juan_Balanta/graphics-spec.md)
- [Edwar — Theme, HUD y resultados](../Edwar_Estacio/graphics-spec.md)
- [Valeria — Personajes](../Valeria_Piza/graphics-spec.md)
- [Krystal — Mapa](../Krystal_Giraldo/graphics-spec.md)
- [Miguel — Roles y feedback](../Miguel_Pabon/graphics-spec.md)
- [GINT — Integración visual](GINT.md)
