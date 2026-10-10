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
