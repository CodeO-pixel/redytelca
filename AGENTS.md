# AGENTS.md — REDYTELCA

Hoja de arranque técnica del repo. Sistema de gestión ISP (tesis de
grado). Backend PHP 8.2 puro + PDO + MariaDB 10.4. Frontend vanilla JS
sin build tools. Uso interno + portal de clientes.

**Este archivo describe el repo: stack, comandos, convenciones de
código y trampas del dominio.**

No lleva:
- Ciclo de trabajo, roles, reglas con AI Studio, rigor de fuentes,
  forma de trabajar → `docs/METODOLOGIA_DESARROLLO_IA.md`.
- Dónde vive cada tipo de información → `docs/GOBERNANZA.md`.
- Estado del proyecto → `MEMORY.md`.
- Specs y su estado → `docs/ROADMAP.md`.

---

## Stack y estructura

- Backend: PHP 8.2 + PDO + MariaDB 10.4. Sin frameworks, sin Composer.
- Frontend: HTML/CSS/JS puro. Sin npm, sin bundler.
- BD: `bd_redytelca.sql` es la fuente de verdad del esquema.
- Endpoints: `api_*.php`. Middleware: `conexion.php` (PDO + auth
  staff/cliente + RBAC dos niveles + contexto de auditoría).
- Frontend: `index.html` + `app.js` + `styles.css`.
- Docs: ver `docs/README.md`. Estado actual y bloque activo: ver
  `MEMORY.md`.

---

## Comandos

- Arranque local: `php -S localhost:8000` desde la raíz.
- Importar BD: `mysql -u root bd_redytelca < bd_redytelca.sql`
- Tests: `php tests/run.php`

---

## Convenciones de código

- Textos de UI, comentarios y documentación en español.
- Nombres de tablas/columnas en snake_case. **Buscar el nombre exacto
  antes de inventar.**
- Patrones existentes (paginación, modales, fetch) se replican, no se
  reinventan.
- Contraseñas: `password_hash()` / `password_verify()`. Nunca texto plano.
- Sesiones: token en tabla `sesiones`, header `X-Session-Token`. Nunca
  `$_SESSION` nativo.
- Archivos PHP puros **no llevan `?>` al final**. Razón: PSR-2 (PHP-FIG)
  §2.2 — el tag de cierre puede introducir whitespace accidental y
  problemas de headers. Todos los archivos del proyecto siguen este
  patrón.

---

## Trampas conocidas del dominio

- `servicios` es 1:N con `clientes`. No asumir 1:1.
- `naps`/`olts`/`nodos` en plural; columnas `id_naps`/`id_olts`/`id_nodos`.
- `contratos.estado` (legal) y `servicios.estado_comercial` (operativo)
  son ejes distintos.
- Transiciones de estado validadas en `transicion_estado` (BEFORE UPDATE
  e INSERT).
- RBAC: dos niveles (visibilidad `rol_modulo_pagina` + operación
  `rol_modulo_permiso`).
- Guard SoD del módulo Configuración vive en `requirePageAccess()`, no
  en `requireOperation()`.
- **phpMyAdmin no exporta CHECK constraints en el dump SQL.** El dump
  de phpMyAdmin 5.2.1 lista las tablas, columnas, índices, FK y triggers,
  pero **omite los `CHECK` constraints** añadidos con `ALTER TABLE ...
  ADD CONSTRAINT chk_xxx CHECK(...)`. Solo exporta los que están
  definidos inline en la columna (ej. `logs.old_value` con
  `CHECK (json_valid(...))`). Consecuencia: auditar CHECKs contra un
  dump de phpMyAdmin produce falsos positivos masivos. **Para verificar
  CHECKs:** consultar `information_schema.CHECK_CONSTRAINTS` o usar
  `mysqldump` desde CLI. Ver `docs/VERIFICACION.md` §2.6.
- **`CONVERT TO CHARACTER SET` de MariaDB 10.4 reconstruye la tabla y
  puede descartar CHECKs.** Aunque el dump no los muestre, la BD los
  conserva en `information_schema`. No asumir pérdida sin verificar.
- Ver `docs/constitution.md` y el plan activo antes de tocar código.

---

## Límites duros del repo

- **Siempre:** buscar el nombre exacto; replicar patrones; explicar el
  porqué.
- **Preguntar antes de:** tocar >1 archivo, agregar dependencias nuevas,
  cambiar el esquema, crear archivos nuevos.
- **Nunca:** reestructurar la BD sin pedido; `$_SESSION` nativo;
  contraseñas en texto plano; inventar nombres.

---

## Verificación

- **Harness casero mínimo**: `tests/run.php` ejecuta
  `tests/smoke.test.php` y `tests/audit_context.test.php`. Verde al
  2026-10-11.
- **No hay CI/CD.** No hay tests de endpoints ni de frontend.
- Después de cada cambio: ejecutar `php tests/run.php`, probar
  manualmente el flujo end-to-end, revisar `DevTools > Network` para las
  llamadas `api_*.php`.
- **Pruebas de backend aisladas**: cerrar todas las pestañas de la app
  antes de probar un endpoint con curl. `initApp()` dispara cargas en
  segundo plano que interfieren con la prueba. Para verificar GET sin
  side-effect, usar curl con la app cerrada.
- Ver `docs/VERIFICACION.md` para lecciones de verificación y checklists.

---

## Memoria

- **Al empezar una sesión:** leer `MEMORY.md`.
- **Al terminar un bloque:** actualizar `MEMORY.md` (estado, decisiones,
  aprendizajes) y `docs/ROADMAP.md` (spec cerrada).
- **Si algo se vuelve regla permanente del repo:** moverlo a este archivo
  o a `docs/constitution.md`.
- **Si algo se vuelve regla del proceso:** moverlo a
  `docs/METODOLOGIA_DESARROLLO_IA.md`.