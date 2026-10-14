# REDYTELCA

Sistema de gestión para ISPs (Proveedores de Servicios de Internet). Proyecto de tesis.

Backend PHP 8.2 + PDO + MariaDB. Frontend vanilla JS sin build tools. Uso interno (staff del ISP) y portal de clientes.

## Stack

- PHP 8.2 (XAMPP)
- MariaDB 10.4
- HTML, CSS, JavaScript puro (sin npm, sin bundler)

## Arranque local

```bash
# Crear la BD e importar esquema y permisos (sin datos de clientes)
mysql -u root -e "CREATE DATABASE bd_redytelca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
mysql -u root bd_redytelca < bd_redytelca_schema.sql
mysql -u root bd_redytelca < bd_redytelca_seed.sql

# Con REDYTELCA_INITIAL_ADMIN_USERNAME, REDYTELCA_INITIAL_ADMIN_EMAIL y
# REDYTELCA_INITIAL_ADMIN_PASSWORD definidas en el entorno:
php crear_admin_inicial.php

# Iniciar la aplicación
php -S localhost:8000
```

Abrir `http://localhost:8000` en el navegador.

## Despliegue en Render

Configura `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` y `DB_PASS` en el
servicio. Importa `bd_redytelca_schema.sql` y después
`bd_redytelca_seed.sql` en la base MySQL una sola vez. Define las variables
`REDYTELCA_INITIAL_ADMIN_USERNAME`, `REDYTELCA_INITIAL_ADMIN_EMAIL` y
`REDYTELCA_INITIAL_ADMIN_PASSWORD`, ejecuta `php crear_admin_inicial.php`
desde el Shell del servicio y elimina esas variables al terminar.

## Estructura

- `api_*.php` — endpoints JSON del backend.
- `conexion.php` — middleware: conexión PDO + autenticación staff/cliente.
- `index.html` + `app.js` + `styles.css` — frontend.
- `bd_redytelca.sql` — dump local de referencia; no se necesita para una instalación limpia.
- `bd_redytelca_schema.sql` — DDL versionable, sin filas de clientes.
- `bd_redytelca_seed.sql` — módulos, páginas y permisos mínimos para el rol Administrador.
- `tests/` — harness de tests. Ejecutar: `php tests/run.php`.
- `docs/` — documentación. Ver `docs/README.md`.
- `AGENTS.md` — reglas operativas para agentes IA.
- `MEMORY.md` — estado del proyecto entre sesiones.

## Estado actual del proyecto

Ver `MEMORY.md`. Resumen: sistema funcional en fase de correcciones post-auditoría.

## Documentación

Toda la documentación vive en `docs/`. Empezar por:

1. `docs/README.md` — índice.
2. `docs/AUDITORIA_2026.md` — hallazgos detectados.
3. `docs/ROADMAP.md` — plan de correcciones.

## Cómo trabajar en este proyecto

Ver `docs/METODOLOGIA_DESARROLLO_IA.md`. Regla principal: cada bloque
de trabajo tiene un plan aprobado antes de tocar código. La IA auditora
redacta prompts, el humano los lleva a AI Studio, la IA auditora verifica
el resultado. Los planes de bloque viven fuera del repositorio, junto a
los documentos de continuidad.