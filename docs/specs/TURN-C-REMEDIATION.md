# Turno C — Correcciones de presentación y verificación

## Objetivo

Resolver tres observaciones del prototipo integrado sin mezclar autoridad ni reescribir las tareas ya cerradas:

1. Reemplazar los puntos de colores por avatares con sprites.
2. Delimitar visual y físicamente caminos, límites y zonas jugables.
3. Verificar que las diferencias de roles y pasivas sean reales, visibles y consistentes.

## Reparto

| Responsable | Tarea | Alcance | Dependencias |
|---|---|---|---|
| Valeria Piza | TC01 — Avatares con sprites | Integrar sprites por rol/equipo en el jugador; conservar collider, input, cámara y autoridad. | GV01–GV03, M01 |
| Krystal Giraldo | TC02 — Límites y zonas jugables | Ajustar colisiones, pasillos, límites y zonas del mapa; ocultar overlays de debug durante gameplay. | K01–K06, V03 |
| Miguel Pabon | TC03 — Verificación de roles/pasivas | Probar diferencias funcionales de Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas. | M01–M05 |
| Edwar Estacio | TC04 — Contrato visible de rol | Confirmar que snapshots autoritativos entregan rol, pasiva y cooldowns al HUD sin recalcular reglas. | E01–E04, M05, K04 |
| Juan Balanta | TC05 — Integración y QA final | Recorrer seis jugadores y consolidar matriz visual/funcional en resoluciones objetivo. | TC01–TC04, J01–J04 |

## Reglas de integración

- Los recuadros, títulos de zonas, estados de barrera y marcadores de spawn son únicamente evidencia/debug; el gameplay normal muestra el mapa limpio.
- Los previews pueden activar overlays explícitamente para capturas y pruebas.
- Ninguna tarea cambia la autoridad del host, el transporte LAN ni las condiciones de victoria sin actualizar el contrato correspondiente.
- Cada responsable trabaja en su propia rama y entrega pruebas, captura/handoff y entrada incremental en `AI_TRACE.md`.
- Juan no integra ramas automáticamente: revisa diff, handoff y pruebas antes de consolidar.

## Criterio de cierre

TC01–TC04 deben estar verificadas antes de TC05. TC05 deja una matriz con `PASS`, `FAIL` o `BLOCKED`, evidencia por caso y defectos priorizados.
