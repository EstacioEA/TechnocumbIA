# Organización de specs individuales

Cada carpeta contiene el spec y el prompt operativo de una persona:

- `Edwar_Estacio/`: integración y estado de partida.
- `Juan_Balanta/`: red LAN y lobby.
- `Valeria_Piza/`: movimiento, cámara y visión.
- `Miguel_Pabon/`: roles, combate y habilidades.
- `Krystal_Giraldo/`: mapa, olla, HUD y QA.

## Uso
1. La persona lee primero `docs/CLI_CONTEXT.md` y `docs/SDD_ORCHESTRATOR.md`.
2. Lee el spec modular correspondiente.
3. Lee su `individual-spec.md` completo.
4. Copia el prompt final de su archivo a la CLI.
5. Trabaja únicamente dentro del alcance indicado.
6. Entrega handoff y evidencia antes de integrar.

Los prompts son guías de ejecución: la CLI debe detenerse y documentar cualquier conflicto, dependencia faltante o decisión no definida.

El plan transversal de presentación visual por relevos está en `docs/specs/graphics/README.md`; cada integrante tiene un `graphics-spec.md` con entrega y criterios observables.

Desglose atómico gráfico: consulta `docs/specs/graphics/README.md` y las subtareas GJ/GE/GV/GK/GM de cada `TASKS.md`; las instrucciones visuales están en cada carpeta como `graphics-spec.md`. Juan no necesita esperar al Theme de Edwar para completar GJ01–GJ05.
