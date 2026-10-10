# Tareas atómicas — Valeria Piza

## V01 — Player base y escena de prueba
- Estado: DONE
- Depende de: ninguno
- Rama sugerida: `Valeria_Piza/player-base`
- Crear CharacterBody2D reutilizable, collider y escena mínima.
- Aceptación: escena carga sin errores; se puede instanciar dos veces; no depende de red.

## V02 — Input y movimiento
- Estado: DONE
- Depende de: V01
- Rama sugerida: `Valeria_Piza/player-movement`
- Configurar WASD, velocidad parametrizada y movimiento local.
- Aceptación: acciones WASD registradas, movimiento con velocidad parametrizada
  y prueba headless de desplazamiento ejecutada.

## V03 — Colisiones y límites
- Estado: DONE
- Depende de: V02, K01
- Rama sugerida: `Valeria_Piza/player-collisions`
- Aplicar paredes, límites y zonas bloqueadas.
- Aceptación: límites del mapa y barrera cerrada bloquean al jugador; caso
  reproducible de colisión documentado.

## V04 — Cámara y visión
- Estado: DONE
- Depende de: V02
- Rama sugerida: `Valeria_Piza/player-camera-vision`
- Cámara local centrada y overlay con aura; HUD fuera del overlay.
- Aceptación: cámara local sigue al jugador con límites; visión limitada usa
  aura del 80%; HUD puede ubicarse sobre la capa del overlay.

## V05 — Prueba de instancias
- Estado: DONE
- Depende de: V03, V04
- Rama sugerida: `Valeria_Piza/player-smoke-test`
- Verificar dos jugadores y documentar integración con el host sin autoridad local.
- Aceptación: dos jugadores instancian sin errores; solo el jugador local
  procesa WASD; el remoto se mueve únicamente con velocidad aplicada por el
  host.

## Tareas gráficas — GV01–GV03
- Spec: `docs/specs/Valeria_Piza/graphics-spec.md`; turno B; baseline G00 disponible sin esperar Theme.

### GV01 — Siluetas y equipo
- Estado: DONE; dependencia: escena jugador.
- Aceptación: dos equipos legibles por color y forma; captura sobre mapa; collider intacto.

### GV02 — Orientación y jugador local
- Estado: DONE; depende de: GV01.
- Aceptación: orientación y marcador local/remoto visibles sin tapar personaje.

### GV03 — Seis instancias y contraste
- Estado: DONE; depende de: GV01/GV02.
- Aceptación: seis jugadores distinguibles con visión activa/inactiva; sin cambios de spawn/input; captura y procedencia en handoff.

## TC01 — Avatares con sprites
- Estado: TODO; depende de: GV01–GV03, M01.
- Rama sugerida: `Valeria_Piza/avatar-sprites`.
- Integrar sprites de los roles disponibles en el componente visual del jugador y conservar la distinción de equipo/local.
- Aceptación: Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas usan avatar reconocible; no aparece el punto de color como representación principal; collider, input, cámara y autoridad permanecen intactos.
- Evidencia requerida: preview de seis jugadores, prueba de instanciación y handoff con procedencia de sprites.
