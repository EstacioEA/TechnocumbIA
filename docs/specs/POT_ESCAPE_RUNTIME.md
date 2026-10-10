# Spec de integración runtime — olla, rescate y escape

- Estado: READY PARA IMPLEMENTACIÓN POR ETAPAS
- Responsable de integración: Edwar Estacio
- Participantes: Juan Balanta, Valeria Piza, Miguel Pabon y Edwar Estacio
- Base revisada: `develop` actualizado a `23fd0a7`.
- Relación con trabajo previo: K02/K03 y M02/M04 continúan DONE como componentes y pruebas aisladas. Este spec no los invalida; define el cierre de la ruta jugable en la sesión LAN real.

## Objetivo

En una partida LAN 3v3, el equipo atacante debe poder capturar a Papa, depositarla en la olla, defenderla durante 20 segundos de reloj autoritativo, rescatarla con Bestia si interactúa a tiempo y, si la cocción termina, usar la salida del lado izquierdo del mapa. Todos los clientes deben mostrar la misma fase, progreso, disponibilidad de salida y resultado recibidos del host.

## Fuente de verdad y componentes existentes

- `PapoiMap.POT_ZONE` es la zona de olla existente; `is_position_in_pot()` valida posiciones en coordenadas del mapa.
- `PapoiMap.ESCAPE_ZONE` es la zona existente de la base/salida izquierda; `is_position_in_escape()` valida su geometría.
- `PapoiCookingEscape` cubre las operaciones de objetivo y refleja fase/tiempo/estado de salida desde snapshots autoritativos; no decrementa un reloj local.
- `GameState` lleva `phase_time_remaining` y es el único responsable de transicionar `POT_COOKING` a `ESCAPE` tras 20 segundos.
- `PapoiGameSession` ya recibe acciones, valida posiciones host-side, conecta Bestia, cocción y resultados; el escape actual valida únicamente al `carrier_id` y resuelve una ronda al llegar.
- `PapoiHUD` lee snapshots y ya rotula fase/temporizador, pero esta tarea debe comprobar que el progreso visible de olla es una barra y no una cuenta paralela local.
- El mapa y su geometría permanecen bajo K01/K02/K03/K06. No rehacer zonas ni mover coordenadas en este trabajo.

## Reglas runtime requeridas

1. **Depositar Papa:** durante `ACTIVE`, únicamente el atacante que realmente porta a Papa puede usar `papoi_interact` (E) dentro de `POT_ZONE`. El host valida rol/equipo, portador y posición server-side. Una petición de cliente contiene solo la intención de interactuar; no declara fase, posición final ni timer.
2. **Estado de olla:** al aceptar el depósito, Papa queda representada en la olla y el estado pasa a `POT_COOKING`. El portador deja de transportar a Papa y queda libre para moverse. Papa debe permanecer en la zona durante la cocción; el jugador no tiene que quedarse parado en la olla.
3. **Reloj único:** la duración es exactamente `20.0` segundos. `GameState.phase_time_remaining` es el único reloj autoritativo que decrementa el host. `PapoiCookingEscape` no decrementa un segundo contador; recibe/representa las transiciones de inicio, rescate y finalización. Una constante compartida evita que estado y UI diverjan.
4. **Barra y réplica:** el host publica fase, tiempo restante, estado/posición de Papa y estado de salida en el snapshot existente. Todos los clientes dibujan el mismo progreso derivado del snapshot (`remaining / 20.0`); el HUD no inicia timers ni acepta datos de cliente.
5. **Rescate:** mientras la fase sea `POT_COOKING`, Bestia solo puede rescatar si su `peer_id` corresponde al rol Bestia activo, ha aparecido según M04 y su posición validada por host está dentro de `CAPTURE_DISTANCE` de la olla. La acción primaria es `papoi_interact` (E); la intención no contiene un peer objetivo arbitrario. El rescate cancela el reloj, vuelve a `ACTIVE`, deja Papa `FREE` dentro de la zona y mantiene la salida desactivada. Una acción a distancia, de otro rol, antes de cocinar o posterior al fin se rechaza sin mutar estado.
6. **Fin de cocción/salida:** al llegar el reloj del host a cero, y solo entonces, Papa pasa a `COOKED`, la fase pasa a `ESCAPE` y la salida izquierda se activa en todas las instancias. Si se rescata antes del cero, no se activa. La señal visual no decide el estado lógico.
7. **Escape:** solo en `ESCAPE` el host acepta el cruce de la `ESCAPE_ZONE`, usando posición autoritativa de cada atacante. El primer atacante válido que cruce gana la ronda; el host rechaza defensores, cruces antes de `ESCAPE` y solicitudes repetidas o posteriores a resolver la ronda. La salida queda disponible para los atacantes, pero no es necesario que escape todo el equipo.
8. **Resultado/marcador:** no conceder puntos por abrir la salida, entrar a la olla o completar la cocción. El primer cruce válido confirmado por el host resuelve una sola ronda y suma exactamente un punto al equipo atacante. El host publica el ganador/motivo y marcador en el snapshot; no suma por atacante ni concede puntos adicionales por cruces posteriores.

## Decisión de producto confirmada — 2026-10-10

Edwar confirmó que el marcador es **un punto por ronda**. Basta que escape una persona atacante para ganar esa ronda; no se requiere que escape el resto del equipo. El primer cruce válido en `ESCAPE` resuelve la ronda y suma una sola vez al equipo atacante. Los cruces posteriores no alteran la ronda ni el marcador. Se conserva el mejor de cinco: la partida termina al llegar un equipo a 3 puntos.

## Contratos congelados para las tareas

- Señal/estado de dominio de olla: `cooking_started`, `cooking_cancelled`, `cooking_completed` (o equivalente ya existente), emitido solo como consecuencia de la transición host.
- Snapshot de partida: conservar los campos existentes (`phase`, `phase_time_remaining`, `papa_state`, `players`, `scores`, `round_number`) y serializar `escape_available`. El resultado/motivo de ronda identifica la victoria por escape usando el contrato existente; no se requiere lista ni contador de escapados. `MatchState` v2 valida el booleano y rechaza snapshots v1.
- Salida visual: componente de presentación con API `set_escape_available(enabled: bool)`; el host/session le pasa el valor de estado y cada cliente usa el valor replicado.
- Acción cliente: reutilizar intención `interact`; el host comprueba equipo/rol y posición real antes de llamar `GameState.register_escape(peer_id)`. No crear RPC que reciba fases, resultados, conteo, timer o posición autoritativos.
- Parámetros: `POT_COOKING_DURATION_SECONDS = 20.0`; proximidad de rescate reutiliza `CAPTURE_DISTANCE` existente; no inventar una distancia distinta.

## Reparto atómico de tareas

### E05-A — Edwar: reloj y contrato autoritativo de objetivo

- Estado: DONE — GameState/MatchState/HUD y espejo de objetivo usan el reloj/snapshot únicos; el módulo de objetivo no decrementa tiempo local.
- Depende de: E01–E04. El componente debe entregar el contrato antes de M06.
- Archivos permitidos: `scripts/shared/game_rules.gd` (nuevo), `scripts/game/game_state.gd`, `scripts/game/match_state.gd`, `scripts/ui/papoi_hud.gd`, `tests/game/`, `tests/ui/` y este contrato si hace falta aclararlo.
- Crear: constante única compartida de 20 s; campo serializable `escape_available`; validación/round-trip; señal autoritativa de transición; barra de cocción read-only en HUD basada solo en snapshot.
- No crear: una segunda cuenta regresiva en HUD o `PapoiCookingEscape`; acciones de red o posiciones.
- Aceptación: el host mantiene POT_COOKING en 19.99 s, cambia exactamente a ESCAPE en cero, serializa progreso/estado de salida, cliente no puede aplicar estado de host y HUD muestra 0–100%/segundos del snapshot; todos los cambios de fase son validables.
- E05-B: API autoritativa y pruebas listas. M06 debe llamar `register_escape(peer_id)` tras validar en el host la posición de quien cruza para cerrar la integración runtime. El primer atacante en `ESCAPE` suma exactamente un punto; pruebas cubren rechazo de fase/rol, duplicados, alternancia y cierre a 3 puntos.

### V06 — Valeria: indicador visual de salida y recorrido jugable

- Estado: READY; puede avanzar en paralelo con E05-A.
- Depende de: zonas ya existentes K01/K02/K06; API visual descrita arriba.
- Archivos permitidos: `scenes/map/escape_exit_indicator.tscn` (nuevo), `scripts/map/escape_exit_indicator.gd` (nuevo), `tests/map/escape_exit_indicator_test.gd` (nuevo) y pruebas del player bajo `tests/player/`. No editar `scripts/map/papoi_map.gd` ni reposicionar zonas de Krystal.
- Crear: componente visual del extremo izquierdo con dos estados claramente legibles (cerrada antes de `ESCAPE`; activa después), señal/función de actualización idempotente y etiqueta/icono además de color. Añadir prueba de que no altera colisiones ni zonas. Ejecutar una prueba de recorrido WASD para confirmar que el atacante llega por corredores existentes a la olla/salida; si la geometría bloquea, documentar reproducción para Krystal en vez de alterar el mapa.
- No crear: autoridad, timer, reglas de marcador o detección final por cliente.
- Aceptación: cerrado durante LOBBY/COUNTDOWN/ACTIVE/POT_COOKING y tras rescate; activo al recibir `ESCAPE`; presentación igual en las resoluciones objetivo; colisiones y Rect2 no cambian.

### M06 — Miguel: depósito de Papa y rescate de Bestia en runtime

- Estado: READY tras congelar E05-A; K02/K03/M02/M04 son dependencias DONE como lógica aislada.
- Archivos permitidos: `scripts/objectives/papoi_cooking_escape.gd`, `scripts/game/papoi_game_session.gd`, `scripts/combat/beast_access_state.gd` solo si la integración requiere un ajuste documentado, y pruebas de integración en `tests/game/` o `tests/combat/`.
- Crear/integrar: depósito con E en olla; quitar la relación de portador después del depósito; Papa queda en POT_ZONE; habilitar acceso de Bestia según M04; rescate contextual con E, proximidad y rol validados por host; cancelar y resetear sin progreso residual; completar desde la transición única del GameState; activar componente de salida de Valeria únicamente al recibir ESCAPE; comprobar la posición host-side de cualquier atacante y llamar `GameState.register_escape(peer_id)` para que el primer cruce resuelva la ronda.
- No crear: contador paralelo; puntos/ganador provisional; acceso de cliente a `GameState`; geometría/mapa nuevo.
- Aceptación: casos positivos/negativos para portador, persona no portadora, atacante ajeno, Bestia válida/inválida, fuera de rango y acciones en fases incorrectas; completar en 20 s exactos; rescate antes del cero vuelve a ACTIVE; estado replicado coincide con GameState.

### J05 — Juan: verificación LAN del flujo vertical

- Estado: READY tras M06, V06 y E05-B.
- Archivos permitidos: `tests/network/`, runner PowerShell correspondiente, `docs/handoffs/` y `AI_TRACE.md`; no editar autoridad, UI ni módulos de juego.
- Crear: runner repetible con host + cinco clientes, timeout global, logs por proceso, cleanup escalonado. Conectar por RPC normal y comprobar en los seis peers: start del lobby, snapshot COUNTDOWN/ACTIVE, depósito, fase POT_COOKING y timer replicado, rescate en una partida de prueba, nuevo intento de cocción completado, ESCAPE habilitado, primer cruce válido, ROUND_RESULT y marcador con un solo punto. No mutar `GameState` ni mover jugadores escribiendo snapshots arbitrarios en clientes.
- Aceptación: tres ejecuciones consecutivas limpias en loopback; resultados coherentes entre seis peers; una sola suma por ronda y partida terminada al llegar a 3; sin `ERROR`, `SCRIPT ERROR`, timeout o cierres forzados. Separar esta evidencia de la prueba manual entre computadores físicos.

## Orden y Definition of Done

1. Edwar publica E05-A (contrato/campo/20 s/barra) y E05-B (un escape gana la ronda y suma un punto).
2. Valeria desarrolla V06 en paralelo y congela el API del indicador antes de la integración.
3. Miguel integra M06 contra E05-A y V06.
4. Edwar completa E05-B conforme a la regla confirmada.
5. Juan ejecuta J05 contra la versión integrada y registra los seis snapshots.
6. Una prueba manual de gameplay comprueba WASD + recorrido, depósito E, barra de 20 s, rescate E, segundo intento, salida izquierda activa y score/resultados. La prueba de loopback no sustituye la LAN física.

Definition of Done: el mapa conserva geometría; el host es única autoridad; ningún timer local cambia reglas; seis peers ven los mismos snapshots; tests cubren rechazo/aceptación; handoff identifica hash, comandos y resultados reales; `AI_TRACE.md` recibe una entrada incremental por cada tarea.
