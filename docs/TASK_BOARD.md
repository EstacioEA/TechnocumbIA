# Tablero de tareas SDD — Papoi

Este tablero resume el orden global. El detalle ejecutable está en `docs/specs/<Integrante>/TASKS.md`.

## Edwar Estacio
`E01` contrato de estado → `E02` ciclo de ronda → `E03` condiciones de resultado → `E04` integración y smoke test → `E05-A` reloj único de olla/contrato/barra → `E05-B` primer escape gana la ronda y suma un punto.

## Juan Balanta
`J01` transporte host/cliente → `J02` lobby y límite 6 → `J03` ready/start → `J04` desconexiones y pruebas multiinstancia → `J05` prueba LAN vertical olla/escape (después de M06/V06; marcador depende de E05-B).

## Valeria Piza
`V01` escena/player base → `V02` input y movimiento → `V03` colisiones → `V04` cámara/visión → `V05` prueba de instancias → `V06` indicador de salida cerrada/activa y verificación de recorrido.

## Miguel Pabon
`M01` enums/roles → `M02` interacción Papa → `M03` impactos/vidas/respawn → `M04` Bestia → `M05` cooldowns/trampa/pasivas → `M06` depósito/rescate de olla en runtime.

## Krystal Giraldo
`K01` mapa/spawns → `K02` zonas y olla → `K03` cocción/rescate/escape → `K04` HUD/resultados → `K05` matriz QA.

## Orden de integración P0
1. `V01`, `K01`, `E01`, `J01` pueden avanzar en paralelo.
2. `V02`, `J02`, `E02` después de sus contratos locales.
3. `M01` y `K02` requieren los contratos de estado y player mínimos.
4. La primera ronda jugable requiere `J03`, `E03`, `M02`, `K03` y movimiento integrado.
5. P1 requiere `M03`, `M04`, `M05`, `K04` y `K05`.

No se debe iniciar online, matchmaking, arte adicional o pulido avanzado antes de completar la primera ronda LAN.

## Integración vertical de olla y escape (P0)

Spec ejecutable: `docs/specs/POT_ESCAPE_RUNTIME.md`. K02/K03/M02/M04 siguen DONE como módulos aislados; esta etapa cierra su interacción dentro de `PapoiGameSession` y la sesión LAN.

Orden: `E05-A` + `V06` en paralelo → `M06` + `E05-B` → `J05` multiinstancia. La regla de marcador está confirmada en el spec: primer atacante en cruzar gana esa ronda y suma un punto al equipo. Geometría K01/K02/K06 no se reimplementa.
