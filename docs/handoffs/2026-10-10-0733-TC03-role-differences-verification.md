# Handoff — TC03 verificación de diferencias de roles y pasivas

- Fecha/hora: 2026-10-10 07:33 (America/Bogota).
- Integrante: Miguel Pabon.
- Rama: `Miguel_Pabon/role-differences-verification`.
- Rama base: `develop`.
- Estado: DONE.
- Tarea: TC03 — Verificación de diferencias de roles y pasivas.

## Matriz de diferencias observadas

| Rol/pasiva | Caso positivo | Rechazo o limitación | Evidencia |
|---|---|---|---|
| Papa | Captura cambia el estado a `CAPTURED` e inicia inmovilización. | Un segundo atacante no puede capturar una Papa ya transportada; cliente no configura el estado. | `test_role_differences_verification.gd` |
| Trolazzo | Puede desplegar una trampa MVP. | Papa/Bestia no pueden desplegarla; cooldown impide repetición inmediata. | `test_role_differences_verification.gd` |
| Bestia | Aparece a los 30 s y puede atacar después de aparecer. | No ataca antes de aparecer ni entra a la olla fuera de cocción; cooldown bloquea repetición. | `test_role_differences_verification.gd` |
| Tanque | Recibe multiplicador de trampa `0.5`. | No recibe bonificación de daño de Cazador ni reducción de sprint de Porta Papas. | `test_role_differences_verification.gd` |
| Cazador | Recibe multiplicador `1.25` contra Bestia. | No recibe reducción de daño de Tanque ni sprint de Porta Papas. | `test_role_differences_verification.gd` |
| Porta Papas | Reduce la inmovilización de Papa en `2.0` segundos por sprint. | Tanque/Cazador no activan esa reducción; el cliente no puede configurar la pasiva. | `test_role_differences_verification.gd` |

## Autoridad, vidas y enfurecimiento

| Regla | Caso positivo | Rechazo o límite | Resultado |
|---|---|---|---|
| Host | Host configura roles, Papa, Bestia, pasivas y vidas. | Clientes no pueden configurar ni aplicar impactos. | Verificado |
| Vidas | Golpe sin Papa reduce exactamente una vida y programa respawn. | Golpe sobre portador no reduce vidas. | Verificado |
| Cooldowns | Ataque de Bestia y trampa aceptan el primer uso. | Segundo uso inmediato es rechazado; tiempos no se declaran desde cliente. | Verificado |
| Enfurecimiento | Cocción completada activa multiplicador de velocidad y cooldown `0.5`. | Sin autoridad host no se activa. | Verificado |

## Números usados

- Aparición de Bestia: `30.0 s`.
- Cooldown básico de Bestia: `3.0 s`.
- Cooldown de trampa: `8.0 s`.
- Respawn: `3.0 s`.
- Vidas iniciales: `3`.
- Reducción Porta Papas: `2.0 s`.
- Multiplicador Tanque contra trampa: `0.5`.
- Multiplicador Cazador contra Bestia: `1.25`.
- Enfurecimiento: cooldown `0.5x`, velocidad `1.25x`.

## Bloqueos y pendientes

- La identificación final de Bestia en `BeastAccessState` aún debe conectarse al rol explícito en la integración; TC03 verifica la diferencia funcional del módulo actual.
- La aplicación física de multiplicadores debe consumir los getters desde el sistema de impactos.
- No se ejecutó una LAN de seis clientes; la verificación es de estados host-authoritativos.
