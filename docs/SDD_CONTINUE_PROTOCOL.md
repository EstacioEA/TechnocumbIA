# Protocolo `Continúa con mi siguiente tarea`

## Objetivo
Permitir que una CLI continúe el trabajo sin que el integrante tenga que explicar manualmente qué sigue.

## Regla de decisión
Cuando el integrante escriba `Continúa con mi siguiente tarea`, la CLI debe:

1. Leer `docs/CLI_CONTEXT.md`, `docs/SDD_ORCHESTRATOR.md`, `docs/CLI_BRANCH_POLICY.md` y el handoff más reciente.
2. Identificar al integrante por la carpeta del spec, la rama activa y el contexto de la sesión.
3. Abrir `docs/specs/<Integrante>/TASKS.md`.
4. Buscar la primera tarea con estado `READY` o, si no existe, la primera `TODO` cuyas dependencias estén `DONE`.
5. No elegir tareas con dependencias pendientes, bloqueadas o pertenecientes a otro integrante.
6. Mostrar antes de editar: ID, objetivo, dependencias, archivos permitidos, criterios de aceptación y rama propuesta.
7. Crear una rama nueva desde `develop` con el formato `Integrante/funcionalidad-en-kebab-case`. Las tareas de implementación no se hacen sobre `develop`.
8. Implementar únicamente esa tarea.
9. Ejecutar las pruebas de la tarea y marcar el resultado como `PASS`, `FAIL` o `BLOCKED`.
10. Crear un handoff con la tarea realizada y el siguiente ID recomendado.
11. Actualizar `TASKS.md` de forma incremental y agregar una entrada a `AI_TRACE.md`.

## Estados permitidos
- `TODO`: todavía no iniciada.
- `READY`: dependencias cumplidas y lista para comenzar.
- `IN_PROGRESS`: solo durante la sesión activa.
- `DONE`: criterios de aceptación cumplidos y evidenciados.
- `BLOCKED`: requiere una decisión, contrato o dependencia externa.

## Regla de continuidad
Una tarea solo puede marcarse `DONE` si todos sus criterios de aceptación tienen evidencia en el handoff. Si una prueba no puede ejecutarse, el estado máximo es `BLOCKED`, salvo que el spec permita explícitamente una prueba manual pendiente.

## Respuesta inicial obligatoria de la CLI
Antes de implementar debe responder:

```text
Integrante detectado: <nombre>
Tarea seleccionada: <ID> — <título>
Estado anterior: <estado>
Dependencias: <lista y estado>
Rama a crear: <rama>
Archivos permitidos: <lista>
Criterios de aceptación: <lista>
¿Existe algún bloqueo? <sí/no + detalle>
```

## Si no hay tarea disponible
La CLI no debe inventar trabajo. Debe informar una de estas situaciones:
- todas las tareas están `DONE`;
- existe una dependencia `BLOCKED`;
- falta identificar al integrante;
- el repositorio no está en la rama o estado esperado;
- los specs tienen una contradicción.

En esos casos debe crear o actualizar un handoff de bloqueo, sin modificar código.
