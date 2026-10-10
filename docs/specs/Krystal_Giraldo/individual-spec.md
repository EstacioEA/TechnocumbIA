# Spec individual — Krystal Giraldo

## Rol
Mapa, olla, zonas de objetivo, HUD y aseguramiento de calidad.

## Objetivo
Montar el mapa jugable y presentar al usuario el objetivo, el tiempo, las vidas, los roles y los resultados de forma clara.

## Alcance
- Integrar el mapa oficial proporcionado por el equipo como referencia visual.
- Configurar navegación/colisiones y puntos de spawn.
- Definir base atacante, base defensora, sala de olla, entrada bloqueable y rutas transitables.
- Implementar zona de olla, temporizador de cocción y rescate por Bestia.
- Implementar condición de escape atacante después de cocinar Papa.
- Crear HUD mínimo de fase, ronda, tiempo, marcador, vidas, rol, pasiva y cooldowns.
- Crear pantallas de resultado de ronda y partida.
- Crear matriz de pruebas para integración LAN 3v3.

## Archivos permitidos
- `scenes/map/`
- `scenes/objectives/`
- `scenes/ui/`
- `scripts/map/`
- `scripts/objectives/`
- `scripts/ui/`
- `tests/qa/`
- `docs/handoffs/`
- `AI_TRACE.md`

## Requisitos funcionales
1. El mapa debe tener colisiones funcionales y puntos de aparición identificables.
2. La olla solo puede iniciar cocción cuando Papa está dentro y el host lo autoriza.
3. La Bestia puede rescatar Papa únicamente durante la cocción.
4. La cocción completada cambia el objetivo a escape.
5. La ronda no termina hasta que los atacantes regresan a su base o se activa una condición defensora.
6. El HUD debe mostrar estados sin depender de logs de consola.
7. La imagen de referencia no debe incorporarse sin confirmar derechos/licencia; usarla como referencia o recurso autorizado del equipo.

## Criterios de aceptación
- [ ] El mapa carga sin errores y tiene límites/collisiones.
- [ ] Existen spawns para los dos equipos y la Papa/Bestia.
- [ ] La olla detecta una Papa válida y muestra estado de cocción.
- [ ] El rescate de Bestia cancela la cocción cuando corresponde.
- [ ] La cocción completada muestra el objetivo de regresar a base.
- [ ] El HUD muestra fase, tiempo, marcador, vidas y rol del jugador.
- [ ] Resultado de ronda y resultado de partida son visibles.
- [ ] Existe una matriz de pruebas con casos P0 para lobby, movimiento, captura, cocción, escape, derrota y desconexión.

## Entregable de sesión
Crear handoff con capturas o descripción reproducible, matriz de pruebas, resultados y defectos priorizados.

## Prompt para la CLI

> Lee `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/specs/03-map-camera-vision.md`, `docs/specs/04-input-ui.md`, `docs/specs/00-game-general.md`, este spec y el handoff más reciente. Implementa únicamente mapa, colisiones, spawns, olla, cocción, escape, HUD y pruebas de QA para Godot 4. No cambies las reglas de red ni inventes condiciones de victoria. Si el arte no tiene licencia confirmada, trátalo como recurso del equipo y registra la procedencia sin afirmar permisos legales. Ejecuta pruebas reproducibles, revisa el diff, crea un handoff y añade una entrada incremental a `AI_TRACE.md`.
