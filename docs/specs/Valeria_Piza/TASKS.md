# Tareas atómicas — Valeria Piza

## V01 — Player base y escena de prueba
- Estado: TODO
- Depende de: ninguno
- Rama sugerida: `Valeria_Piza/player-base`
- Crear CharacterBody2D reutilizable, collider y escena mínima.
- Aceptación: escena carga sin errores; se puede instanciar dos veces; no depende de red.

## V02 — Input y movimiento
- Estado: TODO
- Depende de: V01
- Rama sugerida: `Valeria_Piza/player-movement`
- Configurar WASD, velocidad parametrizada y movimiento local.
- Aceptación: cuatro direcciones funcionan; velocidad no depende de FPS; input está documentado.

## V03 — Colisiones y límites
- Estado: TODO
- Depende de: V02, K01
- Rama sugerida: `Valeria_Piza/player-collisions`
- Aplicar paredes, límites y zonas bloqueadas.
- Aceptación: el jugador no atraviesa obstáculos; caso reproducible de colisión documentado.

## V04 — Cámara y visión
- Estado: TODO
- Depende de: V02
- Rama sugerida: `Valeria_Piza/player-camera-vision`
- Cámara local centrada y overlay con aura; HUD fuera del overlay.
- Aceptación: cámara sigue al jugador; visión limitada visible; HUD legible.

## V05 — Prueba de instancias
- Estado: TODO
- Depende de: V03, V04
- Rama sugerida: `Valeria_Piza/player-smoke-test`
- Verificar dos jugadores y documentar integración con el host sin autoridad local.
- Aceptación: prueba ejecutada o bloqueo explícito con causa.
