# Handoff — preview interactiva del HUD TC04

- Fecha/hora: 2026-10-10 08:34 (America/Bogota).
- Integrante: Edwar Estacio.
- Rama: `develop` local, sin commit.
- Base: `de552bb` (`feat(tc04): connect authoritative role and cooldown HUD context`).
- Objetivo: facilitar una inspección visual del contexto HUD para los seis roles y de los estados de cooldown de TC04.

## Cambios

- Nueva escena: `scenes/ui/tc04_role_state_preview.tscn`.
- Nuevo controlador: `scripts/ui/tc04_role_state_preview.gd`.
- Captura: `docs/handoffs/evidence/tc04/tc04-role-state-1280x720.png`.
- Se actualizó la referencia de evidencia TC04 en `docs/specs/Edwar_Estacio/TASKS.md` y se agregó esta entrada incremental a `AI_TRACE.md`.

La escena usa el HUD real y permite cambiar entre Tanque, Cazador, Porta Papas, Papa, Trolazzo y Bestia con los botones o las teclas 1–6. El panel indica `PREVIEW SIMULADA` y aclara que cada perfil es un ejemplo local. F12 guarda la vista actual; no se sobrescribe la captura automáticamente al abrir la escena. La imagen muestra Bestia, con `beast_basic` bloqueado y `beast_special` listo.

## Verificación

- Godot 4.7.2 gráfico abrió `res://scenes/ui/tc04_role_state_preview.tscn` a 1280×720 y guardó la captura.
- La captura resultante es de 1280×720 y fue revisada visualmente; mapa, selector, contexto del jugador y estados de cooldown son visibles.
- No se ejecutó una sesión LAN ni se generó un snapshot de host en vivo.
- No se creó commit ni se hizo push.

## Limitaciones y siguiente paso

- Los valores de cooldown del selector son fixtures de demostración; no representan tiempos vivos de la partida.
- La rama local `develop` aparece tres commits detrás de `origin/develop`. Los commits pendientes incluyen el preview TC03 (`scenes/ui/role_differences_preview.tscn`); se dejaron sin incorporar para conservar el estado local solicitado.
- Abrir la escena desde Godot: `scenes/ui/tc04_role_state_preview.tscn`.
