# REDYTELCA — puesta en marcha con Docker

## Qué estaba roto (probablemente lo que vio tu profesor)

1. **`conexion.php` tenía hardcodeado el host/usuario/clave del hosting
   InfinityFree** (`sql204.infinityfree.com`, etc.). Eso significa que el
   proyecto solo podía conectarse a esa base remota específica: en
   cualquier otro entorno (tu máquina, Docker, el servidor del profesor)
   la conexión a la base de datos fallaba siempre. Lo corregí para que
   lea host/usuario/clave/puerto de variables de entorno, con valores
   por defecto que apuntan al contenedor de MySQL de docker-compose.
2. **La instalación limpia importaba un esquema legado con datos.** Ahora
  usa `bd_redytelca_schema.sql` (DDL público y sin datos personales) y
  `bd_redytelca_seed.sql` (catálogos RBAC mínimos). El primer
  administrador se crea con `crear_admin_inicial.php`, solo por CLI y
  con credenciales definidas por quien instala.

La conexión PDO toma host, puerto, base, usuario y clave de `DB_HOST`,
`DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS`, con valores locales de
respaldo para XAMPP.

## Algo que no toqué, pero que deberías saber

Dentro de `app/controllers`, `app/models`, `api/roles.php`,
`api/permissions.php`, `api/role_permissions.php`, `api/clientes_listar.php`
e `includes/auth.php` hay un **segundo sistema de roles y permisos que no
está conectado a nada** (no lo usa `index.html` ni `app.js`; `roles_admin.php`
no está enlazada desde ningún menú). El sistema que realmente funciona es
el basado en `rol_modulo_pagina` + tokens en la tabla `sesiones`
(`login.php`, `auth_state.php`, `permisos_listar.php`). Ese código muerto
además compara contraseñas en texto plano en `AuthModel.php`, así que si
alguna vez planeas usarlo, no lo conectes tal cual. No lo borré por si
tu profesor te pide explicarlo o es parte de una entrega anterior, pero
si no lo necesitas, es candidato a eliminar.

## Opción A: probarlo en XAMPP (sin Docker)

1. Copia toda esta carpeta dentro de `htdocs`, por ejemplo:
   `C:\xampp\htdocs\redytelca`.
2. Abre el Panel de Control de XAMPP y arranca **Apache** y **MySQL**.
3. Entra a `http://localhost/phpmyadmin` y crea una base de datos
  llamada **`bd_redytelca`** con cotejamiento `utf8mb4_unicode_ci`.
4. Importa `bd_redytelca_schema.sql` y luego `bd_redytelca_seed.sql`.
5. Define `REDYTELCA_INITIAL_ADMIN_USERNAME`,
  `REDYTELCA_INITIAL_ADMIN_EMAIL` y `REDYTELCA_INITIAL_ADMIN_PASSWORD`
  en el entorno del comando PHP. La contraseña debe tener 12 caracteres
  como mínimo. Desde la raíz del proyecto, ejecuta
  `php crear_admin_inicial.php`; el comando solo funciona si aún no hay
  usuarios.
6. Abre `http://localhost/redytelca/index.html` (panel admin) o
   `http://localhost/redytelca/portal_cliente.php` (portal cliente).

## Opción B: Docker — explicado desde cero

**¿Qué es Docker?** Es un programa que empaqueta tu proyecto junto con
todo lo que necesita para correr (PHP, Apache, MySQL, las versiones
exactas) dentro de "contenedores" — como cajas aisladas. La ventaja: no
importa si tu profesor tiene Windows, Mac o Linux, ni qué versión de
PHP tenga instalada; el contenedor trae la suya propia. Por eso te lo
piden para la entrega: así el proyecto corre igual en cualquier máquina
sin que nadie tenga que instalar XAMPP ni configurar nada a mano.

Ya te dejé los dos archivos que Docker necesita (`Dockerfile` y
`docker-compose.yml`) — no tienes que escribir nada, solo instalar
Docker y ejecutar dos comandos.

### Paso 1: instalar Docker Desktop

Descárgalo de https://www.docker.com/products/docker-desktop/ e
instálalo como cualquier programa (en Windows puede pedirte activar
"WSL2", el instalador te guía). Ábrelo y déjalo corriendo en segundo
plano (verás su ícono en la barra de tareas).

### Paso 2: abrir una terminal en la carpeta del proyecto

En Windows: entra a la carpeta del proyecto en el Explorador de
archivos, haz clic en la barra de direcciones, escribe `cmd` y presiona
Enter — se abrirá una terminal ya ubicada ahí.

### Paso 3: un solo comando

Antes de arrancar, crea un archivo `.env` en la carpeta del proyecto con
la URL donde estará disponible la aplicación y los datos SMTP de una
cuenta autorizada para enviar correo:

```dotenv
REDYTELCA_BASE_URL=http://localhost:8080
SMTP_HOST=smtp.tu-proveedor.com
SMTP_PORT=587
SMTP_USERNAME=tu-cuenta@tu-dominio.com
SMTP_PASSWORD=tu-clave-o-clave-de-aplicacion
SMTP_ENCRYPTION=tls
SMTP_FROM_EMAIL=tu-cuenta@tu-dominio.com
SMTP_FROM_NAME=REDYTELCA
REDYTELCA_INITIAL_ADMIN_USERNAME=
REDYTELCA_INITIAL_ADMIN_EMAIL=
REDYTELCA_INITIAL_ADMIN_PASSWORD=
```

En producción, cambia `REDYTELCA_BASE_URL` por el dominio HTTPS real.
Completa las tres variables `REDYTELCA_INITIAL_ADMIN_*` con credenciales
únicas antes del primer arranque. No reutilices una contraseña de ejemplo.

```bash
docker compose up --build
```

La primera vez tarda unos minutos (descarga PHP y MySQL). Verás mucho
texto pasar en la terminal — es normal, son los dos contenedores
arrancando. Cuando se quede "quieto" mostrando logs de MySQL/Apache sin
errores en rojo, ya está listo. Para apagarlo, `Ctrl+C` y luego
`docker compose down`. Para volver a levantarlo después, el mismo
`docker compose up` (sin `--build`, ya no hace falta reconstruir).

Este comando:
- Construye la imagen PHP 8.2 + Apache (con `pdo_mysql` y `mod_rewrite`
  habilitados, como pide el `.htaccess`).
- Levanta un contenedor MySQL 8.0 y **importa automáticamente
  `bd.sql`** la primera vez que se crea el volumen.
- Espera a que MySQL esté realmente listo antes de arrancar la app
  (`healthcheck`), para evitar el típico error de "connection refused"
  al primer arranque.

Cuando termine, abre **http://localhost:8080** (panel admin) o
**http://localhost:8080/cliente** (portal de cliente).

En otra terminal, crea el primer administrador:

```bash
docker compose exec app php crear_admin_inicial.php
```

El comando falla de forma segura si ya existe algún usuario. Tras crearlo,
borra `REDYTELCA_INITIAL_ADMIN_PASSWORD` del archivo `.env` y recrea la
app con `docker compose up -d --force-recreate app` para retirar el secreto
del entorno del contenedor.

Para cambiar las credenciales de la base de datos, define `DB_HOST`,
`DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS` en `.env` antes de correr
`docker compose up`.

### Reiniciar desde cero

Si necesitas volver a importar esquema y seed en una instalación local de
prueba, borra el volumen de datos:

```bash
docker compose down -v
docker compose up --build
```

(`-v` borra el volumen `db_data`; sin esa bandera, MySQL solo importa los
`.sql` la primera vez que crea el volumen, no en cada arranque).

## Segunda ronda de cambios (base de datos, portal del cliente, diseño)

**Base de datos — errores de datos e integridad que corregí en `bd.sql`:**
- Quité las 8 filas de la tabla `sesiones` que venían en el dump: son
  tokens de sesión de pruebas anteriores con fechas de expiración
  inconsistentes (algunas "expiraban" antes de haberse "creado"). No
  deben viajar en un dump de instalación — las sesiones las crea el
  login en caliente.
- El servicio con `id_servicio=4` tenía longitud **positiva**
  (`66.90300000`) en vez de negativa, lo que lo ubicaba en Asia en vez
  de Venezuela; corregido.
- Dos nodos y tres NAPs tenían coordenadas `0.00000000, 0.00000000`
  (el famoso punto en medio del océano Atlántico, "Null Island"), lo
  que rompía el mapa. Les puse coordenadas reales alrededor de Caracas.
- El equipo `id_equipo=11` estaba físicamente asignado a NAP-10 pero su
  servicio (`id_servicio=11`) cuelga de NAP-12: inconsistencia entre
  equipo y servicio. Corregido para que coincidan.
- El contrato `id_contrato=12` decía "vencido, rescindido por falta de
  pago" pero apuntaba al servicio 12 (activo y con su factura pagada);
  la nota realmente correspondía al servicio 13 (el que sí está
  suspendido). Corregido, y le añadí su factura vencida correspondiente
  (antes no tenía ninguna, así que "vencido por falta de pago" no
  cuadraba con ningún cobro pendiente).
- **Zona horaria:** `conexion.php` ahora sincroniza la zona horaria de
  MySQL con la de PHP en cada conexión (`SET time_zone`). Antes, si el
  servidor de base de datos tenía otra zona horaria que el servidor
  PHP, las sesiones podían darse por expiradas antes de tiempo o durar
  de más, porque `NOW()` de MySQL y `date()` de PHP no coincidían.
- Añadí llaves únicas, índices y restricciones `CHECK` que faltaban:
  una factura no puede repetirse para el mismo servicio y período, los
  montos y precios no pueden ser negativos, los estados de tickets y
  tareas quedan limitados a los valores válidos que ya usa la
  interfaz, y las coordenadas de nodos/NAPs quedan acotadas a rangos
  geográficos válidos. Esto hace que la base de datos rechace datos
  corruptos en vez de aceptarlos silenciosamente.

**Portal del cliente — lo rehice por completo** (`portal_cliente.php` +
`portal_api.php`, nuevo). Antes era una maqueta estática con datos
inventados ("Saldo pendiente: $120,00" fijo) y sin backend real
(llamaba a `/api_pagar.php`, que no existe). Ahora:
- El cliente inicia sesión con su cédula (contraseña inicial = su
  cédula; se le exige cambiarla).
- Ve sus servicios, facturas reales, saldo pendiente real, historial de
  pagos y puede reportar un pago (queda "en revisión" hasta que el
  staff lo valide desde el panel admin).
- Puede abrir tickets de soporte y ver el estado de los que ya creó.
- Diseño responsive de verdad: tarjetas, pestañas arriba en escritorio
  y barra de navegación abajo en el celular (como una app), pensado
  para que lo use el cliente final desde su teléfono.

**Diseño e interfaz del panel admin:**
- Encontré el motivo concreto por el que el sistema "no se acomodaba a
  todas las pantallas": en celulares, el menú lateral no se ocultaba
  por defecto y quedaba tapando el contenido. Ahora en pantallas
  pequeñas arranca oculto, se abre con el botón ☰, y aparece un fondo
  oscuro detrás que lo cierra al tocarlo fuera — como cualquier app
  con menú deslizante.
- Ajustes menores de espaciado para pantallas muy pequeñas (celulares
  angostos) en el encabezado y el login.

No toqué la lógica de negocio del panel admin (clientes, tickets,
facturación, etc.) — esa parte ya funcionaba bien; el trabajo de esta
ronda fue integridad de datos, el portal del cliente y que la interfaz
se vea bien en cualquier tamaño de pantalla.

## Despliegue en Render

Configura `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS` en el
servicio. En una base nueva, importa `bd_redytelca_schema.sql` y luego
`bd_redytelca_seed.sql`; no importes el dump local `bd_redytelca.sql` ni
el antiguo `bd.sql`. Configura temporalmente las variables
`REDYTELCA_INITIAL_ADMIN_USERNAME`, `REDYTELCA_INITIAL_ADMIN_EMAIL` y
`REDYTELCA_INITIAL_ADMIN_PASSWORD`, ejecuta `php crear_admin_inicial.php`
desde el Shell de Render y elimina esas variables al terminar.

Para actualizar una base existente no importes el esquema completo encima:
usa las migraciones correspondientes y conserva un backup previo.


## Cuarta ronda de cambios (frontend: logos, dashboard, mapa, móvil)

Esta ronda partió del `.rar` que subiste (que incluía tus archivos
`DOCUMENTACION.md`, `IMPROVEMENTS.md`, `composer.json` y el renombre de
`bd_redytelca.sql` a `bd.sql`) y corrigió lo siguiente:

- **Docker apuntaba al archivo SQL equivocado.** `docker-compose.yml` y
  esta guía todavía decían `bd_redytelca.sql`, pero el archivo en el
  proyecto ya se llama `bd.sql`. En una instalación nueva, Docker no
  encontraba ese archivo y la base de datos nunca se cargaba. Corregido.
- **Logos recortados / muy pequeños en el panel admin.** El logo real
  mide 322×59 px (y el del menú lateral, 604×97 px) — son wordmarks
  anchos y bajos, no íconos cuadrados. El contenedor del logo en el
  menú lateral (`.brand-logo-wrap`) estaba fijo en 48×48 px, así que el
  logo se encogía hasta quedar casi invisible (una tira de ~9 px de
  alto). Ahora el contenedor usa todo el ancho del menú y una altura de
  hasta 48px, así que el logo se ve completo y legible. También quité
  el texto "REDYTELCA" duplicado al lado (el logo ya lo incluye) para
  que no compita por espacio.
- **El dashboard mostraba las barras en negro.** Esta fue la causa real:
  las gráficas (Chart.js, que dibuja sobre un `<canvas>`) recibían
  colores como el texto literal `'var(--accent)'`. El `<canvas>` no
  entiende variables CSS como el resto de la página — a diferencia de
  un `<div>`, ahí esa cadena de texto no significa nada y Chart.js cae
  en negro por defecto. Afectaba prácticamente todas las gráficas del
  panel (ingresos, facturación, servicios, OLTs, NAPs, tickets). Ahora
  hay una función `cssVar()` que primero resuelve el color real antes
  de dárselo a Chart.js, así que cada gráfica usa sus colores correctos
  (azul, verde, ámbar, rojo según corresponda).
- **El mapa se sobreponía al menú lateral.** El panel del mapa
  (`.map-panel`, donde vive Leaflet) tenía `position: relative` pero
  sin `z-index` propio. Eso significa que no "contenía" el apilamiento
  interno de Leaflet (sus controles llegan a z-index 1000), así que esos
  controles terminaban compitiendo directamente con el menú lateral en
  vez de quedar encerrados dentro del panel del mapa. Con un `z-index`
  explícito en `.map-panel`, todo lo de Leaflet queda contenido ahí
  adentro y el menú siempre queda por delante.
- **Incomodidad en el teléfono:** los campos de texto no tenían
  `font-size` explícito, y por debajo de 16px Safari en iPhone hace zoom
  automático al tocar un campo — de ahí buena parte de la sensación de
  "incómodo". Ahora todos los inputs, selects y textareas usan 16px.
- **Dashboard más profesional:** le agregué una barra de color superior
  a cada tarjeta (distinta por tarjeta), efecto de elevación al pasar
  el mouse, y números más grandes y con más peso — mismo contenido,
  mejor jerarquía visual.

**Importante:** noté que este `.rar` no incluye el cambio que hicimos
para el portal de pago (login solo con cédula + subir el comprobante
arrastrándolo, con `portal_api.php`, `comprobante.php` y la carpeta
`uploads/`) — parece que se quedó solo en el zip que te entregué antes
y nunca se fusionó con tu copia de trabajo. Si quieres que lo integre
de nuevo en esta versión, dímelo y lo hago en el siguiente mensaje.
