-- =================================================================
-- P14 — Planes: velocidad numérica + tecnología
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO
-- `planes.velocidad` es hoy VARCHAR(60) con valores tipo '10 Mbps',
-- '20 Mbps', '50 Mbps', '100 Mbps'. Eso impide:
--   - Filtrar/ordenar numéricamente por velocidad.
--   - Distinguir bajada de subida (necesario para FTTH simétrico,
--     HFC asimétrico, WISP asimétrico).
--   - Reportar capacidad por tecnología (FTTH vs HFC vs WISP).
-- Este script migra a columnas numéricas explícitas y añade el eje
-- `tecnologia` (FTTH/HFC/WISP/OTRO) alineado con la práctica de
-- SmartOLT, Splynx y los ERP ISP de mercado.
--
-- CAMBIO (aditivo, en este orden estricto)
--   1. ADD COLUMN velocidad_bajada_mbps DECIMAL(8,2)
--      ADD COLUMN velocidad_subida_mbps DECIMAL(8,2)
--      ADD COLUMN tecnologia ENUM('FTTH','HFC','WISP','OTRO') DEFAULT 'FTTH'
--   2. UPDATE: parsear primer número de `velocidad` (bajada = subida).
--   3. SELECT diagnóstico OBLIGATORIO antes del DROP.
--      ⚠️ Si alguna fila queda con velocidad_bajada_mbps = NULL
--      (porque su `velocidad` no empezaba con un número), ABORTAR
--      y corregir manualmente esa fila con un UPDATE explícito
--      antes de continuar con el paso 4.
--   4. ALTER TABLE planes DROP COLUMN velocidad;
--   5. ADD CONSTRAINT chk_plan_velocidad_bajada y chk_plan_velocidad_subida.
--
-- NO SE TOCA
--   - `chk_plan_precio`  (existente, se preserva).
--   - `chk_plan_moneda`  (existente, se preserva).
--   - Ninguna otra tabla del esquema.
--
-- ROLLBACK
--   Restaurar backup previo:
--     C:\backups\bd_redytelca_20261013_pre-utc.sql
--   O (parcial, revirtiendo solo este cambio):
--     ALTER TABLE planes ADD COLUMN velocidad VARCHAR(60) NULL AFTER nombre;
--     UPDATE planes SET velocidad = CONCAT(velocidad_bajada_mbps, ' Mbps');
--     ALTER TABLE planes MODIFY COLUMN velocidad VARCHAR(60) NOT NULL;
--     ALTER TABLE planes
--       DROP CONSTRAINT chk_plan_velocidad_bajada,
--       DROP CONSTRAINT chk_plan_velocidad_subida;
--     ALTER TABLE planes
--       DROP COLUMN tecnologia,
--       DROP COLUMN velocidad_subida_mbps,
--       DROP COLUMN velocidad_bajada_mbps;
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- PASO 1 — Añadir columnas nuevas
-- =================================================================

ALTER TABLE planes
  ADD COLUMN velocidad_bajada_mbps DECIMAL(8,2) DEFAULT NULL AFTER velocidad,
  ADD COLUMN velocidad_subida_mbps DECIMAL(8,2) DEFAULT NULL AFTER velocidad_bajada_mbps,
  ADD COLUMN tecnologia ENUM('FTTH','HFC','WISP','OTRO') NOT NULL DEFAULT 'FTTH' AFTER velocidad_subida_mbps;

-- =================================================================
-- PASO 2 — Migrar datos: parsear el primer número de `velocidad`.
-- Formato esperado: '10 Mbps', '20 Mbps', '50 Mbps', '100 Mbps'.
-- Se asume subida = bajada por simplicidad (los planes actuales son
-- todos simétricos en la etiqueta).
-- =================================================================

UPDATE planes SET
  velocidad_bajada_mbps = CAST(SUBSTRING_INDEX(velocidad, ' ', 1) AS DECIMAL(8,2)),
  velocidad_subida_mbps = CAST(SUBSTRING_INDEX(velocidad, ' ', 1) AS DECIMAL(8,2))
WHERE velocidad IS NOT NULL AND velocidad <> '';

-- =================================================================
-- PASO 3 — DIAGNÓSTICO OBLIGATORIO antes del DROP
-- =================================================================

SELECT id_plan, nombre, velocidad, velocidad_bajada_mbps, velocidad_subida_mbps, tecnologia
FROM planes ORDER BY id_plan;

-- ⚠️ ATENCIÓN: revisar la salida de este SELECT antes de ejecutar
--    el paso 4. Si ALGUNA fila tiene velocidad_bajada_mbps = NULL
--    (porque su columna velocidad no empezaba con un número),
--    ABORTAR y corregir manualmente esa fila con un UPDATE
--    explícito antes de continuar con el DROP.

