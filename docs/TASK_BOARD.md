# Tablero de tareas SDD — Papoi

Este tablero resume el orden global. El detalle ejecutable está en `docs/specs/<Integrante>/TASKS.md`.

## Edwar Estacio
`E01` contrato de estado → `E02` ciclo de ronda → `E03` condiciones de resultado → `E04` integración y smoke test.

## Juan Balanta
`J01` transporte host/cliente → `J02` lobby y límite 6 → `J03` ready/start → `J04` desconexiones y pruebas multiinstancia.

## Valeria Piza
`V01` escena/player base → `V02` input y movimiento → `V03` colisiones → `V04` cámara/visión → `V05` prueba de instancias.

## Miguel Pabon
`M01` enums/roles → `M02` interacción Papa → `M03` impactos/vidas/respawn → `M04` Bestia → `M05` cooldowns/trampa/pasivas.

## Krystal Giraldo
`K01` mapa/spawns → `K02` zonas y olla → `K03` cocción/rescate/escape → `K04` HUD/resultados → `K05` matriz QA.

## Orden de integración P0
1. `V01`, `K01`, `E01`, `J01` pueden avanzar en paralelo.
2. `V02`, `J02`, `E02` después de sus contratos locales.
3. `M01` y `K02` requieren los contratos de estado y player mínimos.
4. La primera ronda jugable requiere `J03`, `E03`, `M02`, `K03` y movimiento integrado.
5. P1 requiere `M03`, `M04`, `M05`, `K04` y `K05`.

No se debe iniciar online, matchmaking, arte adicional o pulido avanzado antes de completar la primera ronda LAN.
