# REDYTELCA — puesta en marcha con Docker

## Qué estaba roto (probablemente lo que vio tu profesor)

1. **`conexion.php` tenía hardcodeado el host/usuario/clave del hosting
   InfinityFree** (`sql204.infinityfree.com`, etc.). Eso significa que el
   proyecto solo podía conectarse a esa base remota específica: en
   cualquier otro entorno (tu máquina, Docker, el servidor del profesor)
   la conexión a la base de datos fallaba siempre. Lo corregí para que
   lea host/usuario/clave/puerto de variables de entorno, con valores
   por defecto que apuntan al contenedor de MySQL de docker-compose.
2. **`run_migrations.php` apuntaba a un archivo que no existe**
   (`migrations/002_rbac_dinamico_seed.sql`) — el proyecto solo trae
   `001_create_rbac_tables.sql`. Ejecutar ese script fallaba siempre con
   "archivo no encontrado". Ya no hace falta ejecutarlo para una
   instalación nueva porque `bd_redytelca.sql` ya trae el esquema
   completo (incluye `rol`, `permissions`, `role_permission`,
   `rol_modulo_pagina`, `sesiones`, etc.), pero lo dejé apuntando al
   archivo que sí existe (es idempotente, no rompe nada si lo corres).

No encontré errores de sintaxis PHP (no pude ejecutar `php -l` porque
este entorno no tiene acceso a internet para instalar PHP, pero revisé
manualmente los archivos clave: `conexion.php`, `login.php`, el router,
los controladores y modelos, y las llamadas `fetch()` del frontend). El
resto del código —autenticación, RBAC dinámico, endpoints `api_*.php`—
está bien y usa PDO de forma consistente en todas partes.

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
3. Entra a `http://localhost/phpmyadmin`, crea una base de datos nueva
   llamada **`redytelca`** (cotejamiento `utf8mb4_general_ci`).
4. Con esa base seleccionada, pestaña "Importar" → elige el archivo
   `bd_redytelca.sql` de este proyecto → Importar.
5. Abre `http://localhost/redytelca/index.html` (panel admin) o
   `http://localhost/redytelca/portal_cliente.php` (portal cliente).

Ya no necesitas tocar nada más: dejé `conexion.php` con usuario `root`
y sin clave por defecto, que es la configuración estándar de MySQL en
XAMPP. Si tu XAMPP tiene otro usuario/clave para MySQL, edita las
primeras líneas después del bloque CORS en `conexion.php`.

Usuario admin por defecto (se autocrea en el primer login si la tabla
`usuarios` está vacía): `admin` / `123456`.

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
  `bd_redytelca.sql`** la primera vez que se crea el volumen.
- Espera a que MySQL esté realmente listo antes de arrancar la app
  (`healthcheck`), para evitar el típico error de "connection refused"
  al primer arranque.

Cuando termine, abre **http://localhost:8080** (panel admin) o
**http://localhost:8080/cliente** (portal de cliente).

Usuario admin por defecto (se autocrea en el primer login si la tabla
`usuarios` está vacía): `admin` / `123456`.

Para cambiar las credenciales de la base de datos, copia `.env.example`
a `.env` y edítalo antes de correr `docker compose up`.

### Reiniciar desde cero

Si necesitas que el `.sql` se vuelva a importar (por ejemplo, tras
editar `bd_redytelca.sql`), borra el volumen de datos:

```bash
docker compose down -v
docker compose up --build
```

(`-v` borra el volumen `db_data`; sin esa bandera, MySQL solo importa el
`.sql` la primera vez que crea el volumen, no en cada arranque).

## Segunda ronda de cambios (base de datos, portal del cliente, diseño)

**Base de datos — errores de datos e integridad que corregí en `bd_redytelca.sql`:**
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

## Cómo aplicar estos cambios si ya lo tienes desplegado

- **Docker (local):** `docker compose down -v && docker compose up --build`
  para que se reimporte `bd_redytelca.sql` con las correcciones.
- **Render + base de datos alojada:** vuelve a importar `bd_redytelca.sql`
  en tu base de datos (reemplazando las tablas existentes), y vuelve a
  desplegar el código (push a GitHub si Render está conectado al repo).
- **XAMPP:** reimporta `bd_redytelca.sql` desde phpMyAdmin.

