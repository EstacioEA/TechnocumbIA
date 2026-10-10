# Papoi

Papoi es un videojuego multijugador 2D de persecución y objetivos, ambientado en el campus de la Universidad de los Andes. Dos equipos de tres jugadores compiten: los atacantes intentan capturar a Papa, llevarla a la olla y escapar; los defensores deben detenerlos.

Demo: Ver o descargar Papoi en Google Drive

## Requisitos

- Windows y Godot 4.7.
- Seis puestos de jugador en total, contando al host. Para probar se pueden abrir instancias cliente adicionales como bots de prueba.
- Todos los computadores conectados a la misma red local (LAN).
- Permitir el tráfico UDP del puerto elegido en el firewall del host. El puerto predeterminado es 2456.

El juego utiliza Godot Multiplayer con ENet sobre IP. La versión actual está pensada para partidas en red local; no incluye matchmaking ni juego por Internet.

## Descargar y ejecutar

1. Clona el repositorio:

   git clone https://github.com/EstacioEA/TechnocumbIA.git
cd TechnocumbIA
2. Cambia a la rama que contiene el proyecto jugable:

   git switch develop
3. Abre la carpeta en Godot 4.7 y ejecuta el proyecto. La escena principal abre el menú de Papoi.

También puedes abrirlo desde una terminal si Godot está en PATH:

godot --editor --path .

Para iniciar el juego directamente:

godot --path .

En Windows, si PowerShell no reconoce godot, sustituye el comando por la ruta al ejecutable instalado. La primera apertura puede tardar mientras Godot importa los assets. El repositorio no incluye un binario exportado.

## Cómo jugar

### Objetivo de los atacantes

1. Busca a Papa en el mapa y acércate.
2. Pulsa E para capturarla.
3. Llévala a la sala de la olla y pulsa E para iniciar la cocción.
4. Protege la olla durante los 20 segundos de cocción.
5. Cuando el HUD indique que la salida está activa, lleva a un atacante hasta la salida de su base y pulsa E para completar el escape y ganar la ronda.

El portador puede soltar a Papa con Q. Si recibe un golpe, Papa cae, pero el portador no pierde una vida. Un atacante golpeado sin llevar a Papa pierde una vida y reaparece después de 3 segundos, si todavía le quedan vidas. El equipo atacante pierde la ronda si se agotan todas sus vidas.

### Objetivo de los defensores

Evita que los atacantes completen la secuencia. Papa puede moverse antes de ser capturada. Trolazzo y Bestia pueden atacar a jugadores cercanos con F. Durante la cocción, esos roles pueden entrar a la sala de la olla y tratar de rescatar a Papa con R o E, estando cerca de ella. Un rescate exitoso cancela la cocción.

### Llave de la Torre

La llave aparece en el mapa. Un atacante que no esté transportando a Papa puede recogerla con E al acercarse y usarla en la entrada de la Torre para abrir el acceso. Si recibe un golpe, deja caer la llave. La llave y el acceso se reinician al comenzar cada ronda.

### Rondas y victoria

- Cada ronda dura hasta 7 minutos. Si se acaba el tiempo, ganan los defensores.
- Los defensores también ganan si se agotan todas las vidas de los atacantes.
- Una ronda ganada suma un punto. Gana la partida el primer equipo que alcance 3 puntos; se juegan hasta cinco rondas y los equipos alternan ataque y defensa.
- El host coordina el estado y los resultados de la partida. Una desconexión durante la partida puede invalidarla; no hay reconexión en esta versión.

## Roles y habilidades

Los roles y pasivas se asignan al azar al comienzo de cada ronda y pueden repetirse.

### Defensores

- Papa: es el objetivo que los atacantes deben capturar. Puede moverse antes de ser capturada.
- Trolazzo: puede atacar a los atacantes cercanos y compartir acciones compatibles de ataque y rescate con Bestia.
- Bestia: aparece a los 30 segundos de iniciada la ronda. Puede atacar y entrar a la sala de la olla durante la cocción para intentar rescatar a Papa.

### Atacantes

- Tanque: pasiva orientada a reducir el efecto de las trampas.
- Cazador: pasiva orientada a combatir a Bestia.
- Porta Papas: su sprint puede reducir el tiempo de inmovilización de Papa durante el transporte.

Algunas habilidades, como colocar trampas y el sprint, todavía no tienen una tecla independiente conectada al juego. Sus efectos y valores de balance pueden cambiar.

## Controles

| Tecla | Acción |
|---|---|
| W A S D | Moverse |
| E | Interacción contextual: capturar, recoger la llave, abrir la Torre, iniciar la cocción, rescatar o escapar, según la fase y la posición |
| F | Ataque cercano para roles defensores compatibles |
| Q | Soltar a Papa o atacar con Bestia/Trolazzo, según el rol |
| R | Solicitar rescate durante la cocción si estás cerca de Papa y tienes un rol compatible |
| Enter | Solicitar al host avanzar desde el resultado de ronda; normalmente la siguiente ronda comienza automáticamente |

El host valida las acciones, los roles, las fases y la distancia. Pulsar una tecla no garantiza que la acción se acepte si no se cumplen las condiciones.

## Partidas LAN

### 1. Conecten los computadores

Todos los computadores deben estar conectados a la misma red local. Comprueben que ninguno esté conectado a una red Wi-Fi de invitados, con una VPN activa o sujeto al aislamiento de clientes.

### 2. Permitan la conexión en el computador que será host

Papoi usa ENet sobre UDP, puerto 2456. En el computador host, ejecuta:

ipconfig

Busca la dirección IPv4 del adaptador activo de Wi-Fi o Ethernet y compártela con los demás; por ejemplo, 192.168.1.20. No compartas 127.0.0.1: esa dirección solo funciona dentro del mismo computador.

Si Windows Firewall bloquea la conexión, abre PowerShell como administrador en el host y agrega esta regla para redes privadas:

New-NetFirewallRule -DisplayName "Papoi GameJam UDP 2456" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 2456 -Profile Private

Para eliminarla después de la prueba:

Remove-NetFirewallRule -DisplayName "Papoi GameJam UDP 2456"

### 3. Abre el juego en cada computador

Desde la carpeta del repositorio:

Set-Location "D:\Papoi\TechnocumbIA"
godot --path .

Si PowerShell no reconoce godot, abre el proyecto desde Godot Project Manager y ejecútalo allí, o indica la ruta completa al ejecutable instalado:

& "C:\ruta\donde\instalaron\Godot_v4.7.2-stable_win64.exe" --path "D:\Papoi\TechnocumbIA"

La primera apertura puede tardar mientras Godot importa los assets.

### 4. Crea bots de prueba y conecta a los jugadores

Los bots de prueba se crean abriendo instancias adicionales del juego. Cada instancia ocupa un puesto en el lobby y se conecta como cliente al host.

En PowerShell, ejecuta este comando una vez por cada instancia que quieras abrir:

& "C:\godot\godot\godot.exe.exe" --path "D:\Papoi\TechnocumbIA"

Ajusta las rutas según la ubicación de Godot y del repositorio en ese computador.

1. En un computador, elijan Crear partida. Dejen el puerto en 2456 y creen la sala.
2. En los demás computadores o instancias, elijan Unirse e ingresen la IPv4 del host y el puerto 2456.
3. Si una instancia se ejecuta en el mismo computador que el host, puede conectarse a 127.0.0.1. Desde otro computador, usen la IPv4 del host.
4. Esperen a que cada jugador o instancia aparezca en la lista del lobby.
5. Marquen todos los puestos como listos.
6. Cuando haya seis jugadores en total —incluido el host— y todos estén listos, el host elige Iniciar partida.

Puedes ejecutar el comando varias veces para abrir más instancias cliente y completar los puestos. Con dos computadores pueden comprobar que hay conexión y que el lobby actualiza la lista, pero necesitan seis puestos para iniciar la partida.

### 5. Comprueba que la partida comenzó

Al iniciar, todos deberían llegar al mapa después de la cuenta regresiva. Prueben mover a cada personaje con W, A, S, D y comprueben que las demás instancias también vean el movimiento.

Criterio de éxito: los seis jugadores aparecen en el lobby, todos pueden marcarse listos, el host inicia y los seis llegan a la ronda con su estado visible. El movimiento de cada jugador se refleja en las otras instancias.

## Si un cliente no logra entrar

- Confirma que la IPv4 corresponda al adaptador Wi-Fi o Ethernet activo del host.
- Confirma que el host y los clientes ejecuten la misma versión del repositorio y usen el puerto 2456.
- Revisa la regla del firewall y que Windows considere la red como privada.
- No uses Test-NetConnection para validar este puerto: comprueba TCP, pero Papoi usa UDP.
- Para cerrar la prueba, cierren los clientes uno por uno y el host al final.

## Tecnologías

- Godot 4.7
- GDScript
- Godot High-Level Multiplayer y ENet para partidas LAN

## Trazabilidad

El uso de IA, los cambios explicados y las limitaciones se registran en AI_TRACE.md (AI_TRACE.md). Las especificaciones y handoffs del equipo están en docs/ (docs/).

## Demo y Documentos
Demo: https://drive.google.com/drive/folders/17YGgv_qj3ztIaVTcmwnp6jyymumLt5X7?usp=sharing
Documento de Paopoi: https://docs.google.com/document/d/1kCeZnhlyPSqn7IzHFxMXO63XI9d-aBG5UWqkE4wHmvE/edit?usp=sharing


———
