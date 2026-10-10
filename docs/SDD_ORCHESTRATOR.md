# Orquestador SDD — Papoi

## Objetivo
Coordinar cinco CLIs en paralelo sin duplicación, contratos ambiguos ni cambios incompatibles.

## Ciclo obligatorio por tarea
1. Leer `docs/CLI_CONTEXT.md`, este archivo y el handoff más reciente.
2. Leer el spec modular y atómico asignado.
3. Confirmar dependencias y archivos permitidos.
4. Implementar únicamente el alcance definido.
5. Ejecutar las pruebas y comandos definidos en el spec.
6. Revisar diff y verificar que no se modificaron archivos fuera del alcance.
7. Crear `docs/handoffs/YYYY-MM-DD-HHMM-<tarea>.md` con objetivo, cambios, pruebas, riesgos y siguiente paso.
8. Agregar una entrada nueva al final de `AI_TRACE.md`.

## Contratos compartidos
- El estado de partida tiene una sola autoridad: el host.
- Los clientes envían intención de entrada/acción; el host valida y replica estado.
- No usar RPC para aceptar directamente estados arbitrarios del cliente.
- Los identificadores de jugador, rol, ronda y estado de objetivo deben ser explícitos y serializables.
- Los cambios de protocolo requieren actualizar `docs/specs/01-network-lan.md` antes del código.

## Paralelización
- Las tareas de cada participante deben tocar módulos distintos siempre que sea posible.
- Si dos tareas necesitan una interfaz común, primero se crea el contrato mínimo y se congela hasta integración.
- Ninguna CLI debe cambiar nombres de nodos, señales, RPCs o estructuras de estado compartidas sin registrar el cambio.

## Definition of Done
- Criterios de aceptación del task cumplidos.
- Pruebas ejecutadas y resultado registrado.
- Sin errores nuevos en el editor o ejecución headless.
- Handoff creado.
- Entrada incremental en `AI_TRACE.md`.
- El cambio puede ser explicado por el participante responsable.

## Prioridad de alcance
P0: partida LAN 3v3 jugable con una ronda completa.
P1: mejor de 5, roles, vidas, olla, Bestia y UI clara.
P2: cámara/visión, balance, efectos, sonido y pulido.
P3: matchmaking online, arte adicional y features no necesarias para la demo.
