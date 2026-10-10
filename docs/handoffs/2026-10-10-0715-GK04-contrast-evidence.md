# Handoff GK04 — Contraste y evidencia del mapa

- TEAM_ID: TechnocumbIA
- PARTICIPANT_ID: Krystal Giraldo
- Rama: `Krystal_Giraldo/official-map-remap`

## Implementación

- Preview: `scenes/map/papoi_map_gk04_contrast_preview.tscn`.
- La tecla `V` activa/desactiva el overlay local de visión.
- El preview muestra el mapa oficial, bases/spawns, olla/barrera y un HUD con datos de demostración.
- El HUD se fija en capa 30 y el overlay de visión en capa 20 para conservar legibilidad.

## Pruebas

- `GK04_CONTRAST_EVIDENCE_TEST: PASS`
- Escaneo/importación de Godot 4.7.2: PASS.
- La prueba conserva las regresiones de mapa existentes; no modifica geometría ni autoridad del host.

## Evidencia pendiente

- Captura normal a 1280×720: `docs/handoffs/captura 7 vision normal.png`.
- Captura con overlay activo a 1280×720: `docs/handoffs/captura 7.1 vision activa.png`.
- La procedencia del fondo es `assets/maps/Mapa Base.jpeg`, proporcionado por el equipo; no se afirma licencia externa.
