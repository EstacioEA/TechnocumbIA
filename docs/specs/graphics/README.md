# Planeación gráfica de Papoi

## Objetivo
Completar una capa visual coherente y demostrable para menú, lobby, mapa, personajes, HUD, feedback de acciones y resultados. Los sistemas de juego conservan su autoridad: la presentación lee sus estados y no inventa reglas.

## Relevos de trabajo

### Turno A — Juan + Edwar (ahora)
1. Edwar lidera G00: contrato visual común y Theme inicial. Juan revisa que el contrato cubra el flujo de menú/lobby.
2. Juan lidera GJ01: menú inicial y presentación del lobby LAN, con estados visibles.
3. Edwar lidera GE01: Theme aplicado al HUD, objetivos y paneles de resultado, sin alterar reglas de GameState.
4. Antes del relevo dejan handoff, decisiones, capturas y pendientes. No necesitan esperar al otro turno para avanzar en sus carpetas separadas.

### Turno B — Valeria + Krystal + Miguel (cuando se incorporen)
Cada persona toma su spec en una rama propia después de leer el handoff A y G00: Valeria hace personajes; Krystal, mapa; Miguel, roles y feedback. Los archivos están separados para reducir conflictos. Si requieren tocar una escena compartida, primero acuerdan la interfaz y lo anotan en el handoff.

### Turno C — Juan + Edwar (cuando regresen)
Juan recorre menú → lobby → partida; Edwar revisa HUD y resultados. Juntos ejecutan GINT, integran las ramas revisando los diffs y dejan una matriz visual respaldada por capturas.

## Tareas y dependencias

| ID | Responsable | Entrega revisable | Depende de |
|---|---|---|---|
| G00 | Edwar; Juan revisa | Contrato visual y Theme | Ninguna |
| GJ01 | Juan | Menú y lobby LAN | G00 |
| GE01 | Edwar | HUD, objetivos y resultados | G00 |
| GV01 | Valeria | Seis jugadores visualmente distinguibles | G00 |
| GK01 | Krystal | Mapa y zonas legibles | G00 |
| GM01 | Miguel | Roles e indicadores de acciones | G00 |
| GINT | Juan + Edwar | Flujo visual completo y matriz | GJ01, GE01, GV01, GK01, GM01 |

## Reglas comunes

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
