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
- Estado: TODO
- Depende de: V03, V04
- Rama sugerida: `Valeria_Piza/player-smoke-test`
- Verificar dos jugadores y documentar integración con el host sin autoridad local.
- Aceptación: prueba ejecutada o bloqueo explícito con causa.
