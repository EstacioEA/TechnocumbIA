# Tareas atómicas — Miguel Pabon

## M01 — Contratos de roles y pasivas
- Estado: DONE
- Depende de: E01
- Rama sugerida: `Miguel_Pabon/role-contracts`
- Definir asignación y datos de Papa, Trolazzo, Bestia, Tanque, Cazador y Porta Papas.
- Aceptación: seis jugadores reciben datos serializables; repetición de roles permitida; test de asignación. Evidencia: `tests/combat/test_role_contracts.gd`.

## M02 — Captura y transporte de Papa
- Estado: DONE
- Depende de: M01, V02
- Rama sugerida: `Miguel_Pabon/papa-capture`
- Implementar captura, inmovilidad 20 s, reducción por sprint, soltar y stun de 3 s.
- Aceptación: estados y transiciones se validan en host; golpe al portador suelta sin quitar vida. Evidencia: `tests/combat/test_papa_capture_state.gd`.

## M03 — Impactos, vidas y respawn
- Estado: DONE
- Depende de: M02, E02
- Rama sugerida: `Miguel_Pabon/combat-lives`
- Golpe sin Papa, pérdida de vida, respawn en 3 s y reinicio por ronda.
- Aceptación: pierde exactamente una vida; respawn ocurre una vez; cero vidas activa resultado defensor. Evidencia: `tests/combat/test_combat_lives_state.gd`.

## M04 — Bestia y acceso a olla
- Estado: DONE
- Depende de: M01, K02
- Rama sugerida: `Miguel_Pabon/beast-access`
- Aparición a 30 s, ataque básico/especial y bloqueo fuera de cocción.
- Aceptación: no ataca antes de aparecer; no entra fuera de cocción; cooldowns validan host. Evidencia: `tests/combat/test_beast_access_state.gd`.

## M05 — Trampa, pasivas y enfurecimiento
- Estado: DONE
- Depende de: M03, M04, K03
- Rama sugerida: `Miguel_Pabon/abilities-enrage`
- Trampa MVP, efecto Tanque/Cazador/Porta Papas y enfurecimiento tras cocción.
- Aceptación: cada pasiva tiene efecto observable; cooldown de trampa funciona; Bestia obtiene boost/enrage. Evidencia: `tests/combat/test_abilities_enrage_state.gd`.

## Tareas gráficas — GM01–GM04
- Spec: `docs/specs/Miguel_Pabon/graphics-spec.md`; turno B; puede usar iconos preview antes de integrar eventos.

### GM01 — Iconos roles/pasivas
- Estado: DONE; dependencia: ninguna.
- Aceptación: seis roles con nombre/icono distinguibles a tamaño HUD y monocromo.
- Evidencia: `tests/ui/gm01_role_icons_test.gd`; preview: `tests/ui/gm01_role_icons_preview.gd`.

### GM02 — Estado de cooldown
- Estado: DONE; depende de: GM01.
- Aceptación: disponible/bloqueado/tiempo recibido se distinguen; sin implementar cálculo.
- Evidencia: `scenes/ui/cooldown_feedback.tscn`; `tests/ui/gm02_cooldown_feedback_test.gd`.

### GM03 — Estados de Papa/objetivo
- Estado: DONE; puede avanzar en paralelo con GM01.
- Aceptación: capturada, transportada, cocinando, rescatada y escapada tienen indicadores distintos.
- Evidencia: `scenes/ui/papa_objective_feedback.tscn`; `tests/ui/gm03_papa_feedback_test.gd`.

### GM04 — Impacto/desconexión y preview
- Estado: DONE; depende de: GM02/GM03.
- Aceptación: señales no confunden desconexión con victoria; hoja distingue eventos reales de simulados; HUD y jugadores no se tapan.
- Evidencia: `scenes/ui/role_feedback.tscn`; `tests/ui/gm04_role_feedback_test.gd`; preview: `tests/ui/gm04_role_feedback_preview.gd`.

## TC03 — Verificación de diferencias de roles y pasivas
- Estado: DONE; depende de: M01–M05.
- Rama sugerida: `Miguel_Pabon/role-differences-verification`.
- Verificar mediante pruebas y una matriz que cada rol conserve su diferencia funcional: Papa como objetivo, Trolazzo como transporte, Bestia como acceso/ataque, Tanque, Cazador y Porta Papas con sus pasivas documentadas.
- Aceptación: cada rol tiene al menos un caso positivo y uno de rechazo/limitación; los cooldowns, vidas, captura, rescate y enfurecimiento no se confunden entre roles; el host valida las acciones.
- Evidencia requerida: matriz de roles, pruebas automatizadas y handoff con diferencias observadas y bloqueos.
- Evidencia: `tests/combat/test_role_differences_verification.gd`; `docs/handoffs/2026-10-10-0733-TC03-role-differences-verification.md`.

## M06 — Depósito de Papa y rescate de Bestia en runtime
- Estado: READY tras congelar E05-A; M02/M04 y K02/K03 son dependencias DONE a nivel de componente, no aceptación de la ruta LAN completa.
- Depende de: E05-A, V06 API de salida, M02, M04, K02/K03.
- Rama sugerida: `Miguel_Pabon/pot-rescue-runtime`.
- Archivos: `scripts/objectives/papoi_cooking_escape.gd`, `scripts/game/papoi_game_session.gd`, `scripts/combat/beast_access_state.gd` solo si se justifica; test runtime bajo `tests/game/` o `tests/combat/`.
- Integrar E/`papoi_interact` para que el portador de Papa la deposite dentro de `POT_ZONE`, dejar a Papa en olla y liberar al portador. Integrar rescate contextual con la misma interacción: Bestia válida y aparecida, dentro de distancia existente; el host cancela y reinicia a ACTIVE. `PapoiCookingEscape` ya refleja el snapshot de GameState y no posee reloj; consumir esa transición única y activar el indicador V06 solo al entrar en ESCAPE. Validar en host la posición de cualquier atacante y llamar `GameState.register_escape(peer_id)`; el primero resuelve la ronda y suma un punto.
- No duplicar reloj, fases ni marcador; no recibir autoridad/posición por payload cliente; no mover geometría del mapa.
- Aceptación: pruebas positivas/negativas para interacción, rol, fase, portador y proximidad; rescate no deja timer/estado residual; seis peers renderizan el mismo resultado del host.
