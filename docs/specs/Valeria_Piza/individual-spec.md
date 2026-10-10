# Spec individual — Valeria Piza

## Rol
Movimiento del jugador, colisiones, cámara centrada y visión limitada.

## Objetivo
Crear un controlador de jugador reutilizable para los seis participantes, con movimiento de teclado y presentación 2D isométrica.

## Alcance
- Implementar `CharacterBody2D` para movimiento.
- Configurar acciones de teclado WASD.
- Aplicar colisiones con paredes, límites y zonas bloqueadas.
- Crear cámara centrada en el jugador local.
- Crear overlay oscuro con aura de visión aproximada del 80% del campo visual.
- Mantener HUD fuera del área oscurecida.
- Preparar sincronización visual sin permitir que el cliente determine el estado autoritativo.

## Archivos permitidos
- `scripts/player/`
- `scenes/player/`
- `scripts/camera/`
- `scenes/camera/`
- `assets/shaders/` o `scenes/ui/vision/`
- `tests/player/`
- `docs/handoffs/`
- `AI_TRACE.md`

## Requisitos funcionales
1. WASD mueve al jugador en cuatro direcciones o en el esquema definido por el mapa.
2. El jugador no atraviesa colisiones.
3. La cámara sigue únicamente al jugador local.
4. El overlay no oscurece el HUD.
5. El movimiento local puede enviar intención al host, pero no confirmar posición autoritativa.
6. El componente debe poder instanciarse para cualquier rol.

## Criterios de aceptación
- [ ] El jugador se mueve con WASD en una escena de prueba.
- [ ] Las paredes y límites bloquean el movimiento.
- [ ] La cámara permanece centrada en el jugador local.
- [ ] El overlay muestra un área visible alrededor del jugador.
- [ ] El HUD permanece legible sobre el overlay.
- [ ] El componente de jugador puede instanciarse al menos dos veces sin errores.
- [ ] Existe una prueba manual o automatizada documentada para colisiones y cámara.

## Entregable de sesión
Crear handoff con controles, escena de prueba, archivos cambiados, comandos y defectos visuales conocidos.

## Prompt para la CLI

> Lee `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/CLI_BRANCH_POLICY.md`, `docs/specs/03-map-camera-vision.md`, `docs/specs/04-input-ui.md`, este spec y el handoff más reciente. Antes de modificar cualquier archivo, verifica el estado del repositorio, actualiza `main` y crea una rama nueva exactamente con el formato `Valeria_Piza/Funcionalidad`, usando una funcionalidad concreta en kebab-case, por ejemplo `Valeria_Piza/player-camera`. No implementes directamente sobre `main`. Si la rama ya existe, hay cambios locales sin registrar o no puedes verificar la rama activa, detente y documenta el bloqueo. Confirma la rama con `git branch --show-current` antes de editar. Implementa únicamente el controlador CharacterBody2D, input WASD, colisiones, cámara local y visión limitada para Godot 4. No alteres el estado de partida ni las reglas de roles. Usa componentes reutilizables y deja constantes de velocidad/zoom claramente identificadas. Ejecuta una escena de prueba, revisa el diff, crea un handoff con la rama y los commits, y añade una entrada incremental en `AI_TRACE.md` con resultados reales.
