-- =================================================================
-- P9 — Fix zona horaria en sesiones
-- Fecha: 2026-10-13
-- Motivo: unificar sesiones en UTC. Bug detectado: expira_en < creado_en
--         por mezcla TIMESTAMP (auto-UTC) + DATETIME (local PHP).
-- Backup previo: C:\backups\bd_redytelca_20261013_pre-utc.sql
-- Rollback: restaurar el backup.
-- =================================================================

USE bd_redytelca;

-- 1. Fijar la sesión de migración a UTC para que la conversión
--    TIMESTAMP -> DATETIME lea el TIMESTAMP como UTC literal.
SET time_zone = '+00:00';

-- 2. Drop del CHECK que bloquea el ALTER por la fila id_sesion=109.
ALTER TABLE sesiones DROP CONSTRAINT chk_sesion_expira;

-- 3. Convertir creado_en de TIMESTAMP a DATETIME.
--    Con la sesión en UTC, MariaDB escribe el valor UTC como literal.
--    DEFAULT CURRENT_TIMESTAMP se conserva (ahora devuelve UTC).
ALTER TABLE sesiones
  MODIFY COLUMN creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- 4. Corregir filas con expira_en <= creado_en.
--    Recalcular como creado_en + 30 días.
UPDATE sesiones
SET expira_en = DATE_ADD(creado_en, INTERVAL 30 DAY)
WHERE expira_en <= creado_en;

-- 5. Re-añadir el CHECK ya con datos consistentes.
ALTER TABLE sesiones
  ADD CONSTRAINT chk_sesion_expira CHECK (expira_en > creado_en);

-- 6. Verificación.
SELECT
    (SELECT COUNT(*) FROM sesiones WHERE expira_en <= creado_en) AS invalidas_esperado_0,
    (SELECT COUNT(*) FROM sesiones)                              AS total_sesiones;

-- =================================================================
-- Fin P9.
-- =================================================================