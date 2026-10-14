-- =================================================================
-- P15 — Restaurar CHECKs perdidos por P8b (CONVERT TO CHARACTER SET)
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo DB-14 (ver MEMORY.md)
--
-- MOTIVO
-- El `ALTER TABLE ... CONVERT TO CHARACTER SET utf8mb4 COLLATE
-- utf8mb4_unicode_ci` de P8b reconstruye la tabla internamente. En
-- MariaDB 10.4 ese rebuild descartó 6 CHECK constraints que existían
-- desde Fase 0 y que ningún script posterior repuso. La BD viva
-- quedó sin estas defensas a nivel de esquema.
--
-- El resto de CHECK constraints (chk_clientes_cedula, chk_facturas_periodo,
-- chk_config_singleton, etc.) sobrevivieron al rebuild. Solo estos 6
-- se perdieron.
--
-- NO INCLUYE:
--   - chk_sesion_expira        → va en P9, paso 5 (ya planificado).
--   - chk_equipo_estado_servicio → va en P12 (ya planificado).
--   - chk_plan_velocidad_bajada → va en P14-bis (ya planificado).
--   - chk_plan_velocidad_subida → va en P14-bis (ya planificado).
--
-- ROLLBACK
--   ALTER TABLE equipos   DROP CONSTRAINT chk_equipo_mac;
--   ALTER TABLE equipos   DROP CONSTRAINT chk_equipo_puerto;
--   ALTER TABLE logs      DROP CONSTRAINT chk_log_actor;
--   ALTER TABLE sesiones  DROP CONSTRAINT chk_sesiones_un_tipo;
--   ALTER TABLE sesiones  DROP CONSTRAINT chk_sesion_revocacion;
--   ALTER TABLE sesiones  DROP CONSTRAINT chk_sesiones_discriminador;
--
-- ORDEN DE EJECUCIÓN
--   1. Diagnóstico previo (SELECT) — todos los contadores en 0.
--   2. ALTER TABLE (3 tablas).
--   3. Verificación final.
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- DIAGNÓSTICO PREVIO — ninguno debe devolver filas
-- =================================================================

SELECT 'equipos_mac_invalida' AS check_name, id_equipo, direccion_mac
FROM equipos
WHERE direccion_mac NOT REGEXP '^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$'
UNION ALL
SELECT 'equipos_puerto_invalido', id_equipo, CAST(num_puerto_nap AS CHAR)
FROM equipos
WHERE num_puerto_nap <= 0;

SELECT 'sesiones_discriminador_roto' AS check_name, id_sesion
FROM sesiones
WHERE NOT (
  (tipo_usuario = 'staff'   AND id_usuario IS NOT NULL AND id_credencial IS NULL) OR
  (tipo_usuario = 'cliente' AND id_credencial IS NOT NULL AND id_usuario IS NULL)
);

SELECT 'sesiones_revocacion_rota' AS check_name, id_sesion
FROM sesiones
WHERE NOT (
  (revocado_en IS NULL     AND motivo_cierre IS NULL) OR
  (revocado_en IS NOT NULL AND motivo_cierre IS NOT NULL)
);

SELECT 'logs_actor_roto' AS check_name, id_log
FROM logs
WHERE NOT (
  (tipo_actor = 'staff'   AND id_usuario IS NOT NULL AND id_credencial IS NULL) OR
  (tipo_actor = 'cliente' AND id_credencial IS NOT NULL AND id_usuario IS NULL) OR
  (tipo_actor = 'sistema' AND id_usuario IS NULL AND id_credencial IS NULL)
);

-- ⚠️ Si alguna de las 4 SELECT devuelve filas, ABORTAR y limpiar
--    manualmente antes de continuar.

-- =================================================================
-- ALTER TABLE — re-añadir los 6 CHECKs perdidos
-- =================================================================

ALTER TABLE equipos
  ADD CONSTRAINT chk_equipo_mac CHECK (
    direccion_mac REGEXP '^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$'
  ),
  ADD CONSTRAINT chk_equipo_puerto CHECK (num_puerto_nap > 0);

ALTER TABLE sesiones
  ADD CONSTRAINT chk_sesiones_un_tipo CHECK (
    (id_usuario IS NOT NULL AND id_credencial IS NULL) OR
    (id_usuario IS NULL AND id_credencial IS NOT NULL)
  ),
  ADD CONSTRAINT chk_sesion_revocacion CHECK (
    (revocado_en IS NULL     AND motivo_cierre IS NULL) OR
    (revocado_en IS NOT NULL AND motivo_cierre IS NOT NULL)
  ),
  ADD CONSTRAINT chk_sesiones_discriminador CHECK (
    (tipo_usuario = 'staff'   AND id_usuario IS NOT NULL AND id_credencial IS NULL) OR
    (tipo_usuario = 'cliente' AND id_credencial IS NOT NULL AND id_usuario IS NULL)
  );

ALTER TABLE logs
  ADD CONSTRAINT chk_log_actor CHECK (
    (tipo_actor = 'staff'   AND id_usuario IS NOT NULL AND id_credencial IS NULL) OR
    (tipo_actor = 'cliente' AND id_credencial IS NOT NULL AND id_usuario IS NULL) OR
    (tipo_actor = 'sistema' AND id_usuario IS NULL AND id_credencial IS NULL)
  );

-- =================================================================
-- VERIFICACIÓN FINAL — debe devolver 6 filas, todas con creado=1
-- =================================================================

SELECT 'chk_equipo_mac' AS check_name, COUNT(*) AS creado
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_equipo_mac'
UNION ALL
SELECT 'chk_equipo_puerto', COUNT(*)
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_equipo_puerto'
UNION ALL
SELECT 'chk_log_actor', COUNT(*)
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_log_actor'
UNION ALL
SELECT 'chk_sesiones_un_tipo', COUNT(*)
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_sesiones_un_tipo'
UNION ALL
SELECT 'chk_sesion_revocacion', COUNT(*)
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_sesion_revocacion'
UNION ALL
SELECT 'chk_sesiones_discriminador', COUNT(*)
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'bd_redytelca' AND CONSTRAINT_NAME = 'chk_sesiones_discriminador';

-- =================================================================
-- Fin P15.
-- =================================================================