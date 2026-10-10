# Handoff J06 — Prueba LAN física bloqueada

- Fecha: 2026-10-10 02:26 (America/Bogota)
- Equipo / participante: TechnocumbIA / Juan Diego Balanta
- Rama de trabajo: `Juan_Balanta/runtime-disconnect-bridge`
- Estado: BLOCKED; no se dispone de un segundo equipo físico en la sesión.
- Resultado: no se ejecutó una prueba entre computadoras. No marcar como PASS.

## Procedimiento para completar J06

1. Conectar dos equipos Windows a la misma red privada. Registrar versión exacta de Godot 4 y anotar IPs con el último octeto redactado (por ejemplo, `192.168.1.x`), sin guardar direcciones públicas.
2. En el equipo host, abrir el proyecto Papoi, crear lobby en el puerto UDP `2456` y copiar la IPv4 privada activa obtenida con `ipconfig`.
3. En el equipo cliente, abrir el mismo proyecto, ingresar la IPv4 privada del host y el puerto `2456`, y conectarse.
4. Verificar en ambas ventanas que el lobby muestre a ambos peers. Desconectar el cliente antes del inicio y confirmar que el host lo retire del roster y muestre el estado/mensaje de desconexión.
5. Si Windows Firewall bloquea el tráfico, permitir Godot o UDP `2456` únicamente en el perfil de red privada y repetir. Registrar el resultado con firewall habilitado y la observación visible en ambos procesos.
6. Actualizar este handoff con PASS o FAIL, versiones, subredes redactadas, puerto, pasos y evidencia observada. Cambiar J06 a DONE únicamente si conexión y salida se verificaron en los dos equipos.

## Evidencia disponible

La suite local multiinstancia de J01-J05 pasó en Godot 4.7.2, pero utiliza procesos del mismo equipo y no valida conectividad entre adaptadores LAN, aislamiento de clientes Wi-Fi ni firewall físico. Esa evidencia no sustituye esta prueba.

## Archivos

- `docs/handoffs/2026-10-10-0226-J06-lan-physical-blocked.md`
- `docs/specs/Juan_Balanta/TASKS.md`
- `AI_TRACE.md`

No se modificó código para esta tarea ni se creó commit.
