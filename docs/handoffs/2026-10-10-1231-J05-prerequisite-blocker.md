# J05 — bloqueo por prerequisitos runtime

- Evento/equipo: GameJam / TechnocumbIA
- Responsable: Juan Diego Balanta
- Rama: `Juan_Balanta/lan-pot-escape-test`
- Base: `develop` en `f1c04f4` (`Update project metadata and add new classes`), limpia y alineada con `origin/develop` al iniciar.
- Resultado: **BLOCKED**. No se implementó un runner apuntando al contrato anterior.

## Estado de dependencias comprobado

- **V06:** DONE e integrada. El indicador ofrece `set_escape_available(bool)`; su entrega está documentada en `docs/handoffs/2026-10-10-1215-V06-escape-exit-indicator.md`.
- **E05-A:** sigue en READY en `docs/specs/Edwar_Estacio/TASKS.md`. El contrato exige un único reloj de 20 s y `escape_available` serializado.
- **M06:** sigue en READY en `docs/specs/Miguel_Pabon/TASKS.md` y depende de E05-A; aún falta el depósito/rescate integrados a la sesión runtime.
- **E05-B:** sigue en READY en `docs/specs/Edwar_Estacio/TASKS.md` y depende de E05-A. La regla de puntuación ya está decidida; falta implementarla.

## Evidencia en el código de esta base

- `scripts/game/game_state.gd` define `POT_COOKING_DURATION_SECONDS := 30.0`.
- `scripts/objectives/papoi_cooking_escape.gd` también define `COOKING_DURATION_SECONDS := 30.0`, mantiene `cooking_remaining` y lo decrementa en `advance_host_clock()`; `PapoiGameSession` llama ese reloj. Esto contradice el reloj único de 20 s requerido por E05-A.
- El snapshot de `scripts/game/match_state.gd` no incluye `escape_available` en sus campos/validación actuales.
- Sin E05-A/M06/E05-B integrados, J05 no tiene transiciones/snapshot finales contra los cuales verificar rescate, cocción, escape y exactamente un punto en los seis procesos.

## Para reanudar

1. Integrar E05-A en la rama compartida: reloj único de 20 s y snapshot validado con `escape_available`.
2. Integrar M06 contra E05-A y V06: depósito, rescate y escape autorizados por host.
3. Integrar E05-B y confirmar en runtime resultado/marcador de un punto por ronda y cierre al llegar a tres.
4. Actualizar `develop`, ejecutar el runner J05 tres veces consecutivas y guardar logs de los seis peers.
5. Documentar por separado la prueba manual entre computadores físicos.

## Pruebas y límites

- Pruebas J05: **no ejecutadas**; prerequisitos ausentes. No se reporta PASS.
- Inspecciones realizadas: estado/branch/HEAD, estados E05-A/E05-B/M06/V06, símbolos del runtime y contrato `POT_ESCAPE_RUNTIME.md`.
- No se modificó gameplay, UI, autoridad, payloads ni pruebas. No se alteraron archivos de compañeros.
- La spec marca J05 como lista tras sus dependencias; este handoff aclara que ese estado es condicional y que, en `f1c04f4`, E05-A, M06 y E05-B no están integradas.

## Seguimiento tras actualizar referencias remotas

- `origin/Edwar_Estacio/pot-escape-state` ahora apunta a `6b86109`, que contiene el commit `43a1a8b` con trabajo de E05-A/E05-B aún fuera de `origin/develop`.
- En esa rama E05-A figura **IN_PROGRESS**: ya aparecen la constante compartida de 20 s y el campo serializable de salida, pero la propia spec asigna a M06 retirar el reloj paralelo e integrar la sesión.
- E05-B figura **API DONE**; falta que M06 conecte `register_escape(peer_id)` al cruce autoritativo dentro de la ruta runtime.
- M06 sigue **READY** en `origin/develop` y no aparece una rama remota de Miguel para esa tarea. J05 continúa bloqueada; no se ejecutaron pruebas ni se copiaron cambios de la rama de Edwar.
- Referencia de entrega parcial de Edwar: `docs/handoffs/2026-10-10-1222-Edwar-E05-pot-escape-state-score.md`.
