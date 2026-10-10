# Spec modular — Mapa, cámara y visión

## Mapa
Usar un solo mapa 2D con apariencia isométrica basado en el arte proporcionado por el equipo. Las zonas mínimas son: bases, rutas transitables, sala de olla, entrada bloqueable y puntos de spawn.

## Cámara
- Centrada en el jugador local.
- Visión limitada mediante overlay oscuro y aura circular o elíptica que cubre aproximadamente 80% del campo visual.
- La visión es principalmente una mecánica visual; no debe ocultar información crítica de UI.

## Implementación prevista
- TileMap/TileMapLayer isométrico.
- Y-sort para profundidad.
- CharacterBody2D para personajes.
- Filtro nearest.
- Colisiones separadas para navegación, sala de olla y límites.

## Acceptance criteria
- El jugador no atraviesa paredes ni límites.
- La cámara sigue al jugador sin abandonar el mapa.
- La sala de olla y las bases son identificables.
- El overlay no cubre el HUD ni impide leer el estado de ronda.
