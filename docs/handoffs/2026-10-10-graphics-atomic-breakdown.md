# Handoff — Desglose atómico de tareas gráficas

- Equipo: TechnocumbIA
- Solicitante: Juan Diego Balanta
- Rama: `Juan_Balanta/graphics-atomic-tasks`, basada en `develop` actualizado.
- Estado: documentos de planeación actualizados; no se cambió código ni se ejecutaron pruebas del juego.

## Cambios de planeación

- Turno A: Juan tiene GJ01–GJ05 para cascarón de menú, host, join/IP, lobby y revisión visual. No dependen del Theme, del código ni de la aprobación de Edwar; se usa el baseline provisional G00 ya escrito.
- Turno A en paralelo: Edwar tiene GE01–GE06 para Theme, jerarquía HUD, fases/timers, rol/cooldown, resultados y preview.
- Turno B: Valeria GV01–GV03; Krystal GK01–GK04; Miguel GM01–GM04. Se habilitó trabajo paralelo en áreas y assets separados.
- Turno C: GINT01–GINT03 para ensamblaje, matriz visual y cierre/handoff.

## Criterio de relevo

Juan no necesita que Edwar integre o revise el Theme para completar su flujo visible de menú y lobby. La paleta provisional está definida en `VISUAL_DIRECTION.md`; si el Theme final difiere, la adopción y revisión se realiza en GINT. Ninguna tarea autoriza cambios de gameplay, autoridad, colisiones o red.

## Verificación

Se comprobarán enlaces, desgloses de tareas y `git diff --check`. No se ejecutaron pruebas Godot, porque el cambio es documental. No se creó commit.

