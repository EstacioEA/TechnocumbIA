# Política obligatoria de ramas para CLIs — Papoi

Esta política aplica a todas las CLIs y a todos los specs del proyecto.

## Regla obligatoria
Antes de modificar, crear o eliminar cualquier archivo de implementación, la CLI debe crear y cambiarse a una rama nueva basada en la rama por defecto actual (`main`), salvo que el participante indique explícitamente otra rama base.

La CLI no debe implementar directamente sobre `main`.

## Convención de nombre
La rama debe seguir exactamente este formato:

```text
(Integrante)/(Funcionalidad)
```

Convención recomendada para el proyecto:

```text
Nombre_Apellido/funcionalidad-en-kebab-case
```

Ejemplos válidos:

```text
Edwar_Estacio/game-state
Juan_Balanta/lan-lobby
Valeria_Piza/player-camera
Miguel_Pabon/combat-roles
Krystal_Giraldo/map-pot-hud
```

## Procedimiento obligatorio
La CLI debe ejecutar o solicitar al participante un procedimiento equivalente a:

```bash
git status
git fetch origin
git switch main
git pull --ff-only origin main
git switch -c Nombre_Apellido/funcionalidad-en-kebab-case
```

Después debe verificar:

```bash
git branch --show-current
git status --short
```

La salida de `git branch --show-current` debe coincidir exactamente con la rama asignada antes de comenzar la implementación.

## Reglas de seguridad
- No borrar ni reutilizar una rama de otro integrante.
- No crear ramas con nombres ambiguos como `test`, `fix`, `changes` o `feature` sin integrante.
- No hacer `force push`.
- No reescribir historial ni cambiar timestamps.
- Si la rama ya existe, detenerse y pedir confirmación; no continuar sobre ella automáticamente.
- Si hay cambios locales sin commit, detenerse y registrarlo en el handoff antes de cambiar de rama.
- Si el repositorio remoto no está disponible, no afirmar que la rama fue creada remotamente; registrar el bloqueo.

## Integración
Cada rama debe producir commits pequeños y explicables. La integración a `main` se hará mediante revisión explícita del equipo, preferentemente con Pull Request. La CLI debe registrar en el handoff:

- nombre exacto de la rama,
- rama base,
- commit(s) creados,
- archivos modificados,
- pruebas ejecutadas,
- estado de integración.

## Texto que debe añadirse al prompt de cada CLI

> Antes de implementar, lee `docs/CLI_BRANCH_POLICY.md`. Verifica el estado del repositorio y crea una rama nueva desde `main` usando exactamente el formato `Integrante/Funcionalidad`, por ejemplo `Nombre_Apellido/funcionalidad-en-kebab-case`. No modifiques `main`. Si la rama ya existe, hay cambios locales sin registrar o la base no está actualizada, detente y documenta el bloqueo. Confirma la rama activa antes de editar archivos y registra su nombre en el handoff final.
