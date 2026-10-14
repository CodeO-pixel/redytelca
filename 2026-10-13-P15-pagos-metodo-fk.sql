-- =================================================================
-- P15 — pagos.metodo_pago ENUM → FK a metodos_pago
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo + plan maestro P13-P29
-- Backup previo obligatorio: C:\backups\bd_redytelca_20261013_pre-p15.sql
--
-- MOTIVO
-- `pagos.metodo_pago` es un ENUM hardcodeado. Existe la tabla
-- `metodos_pago` con seed (4 filas: transferencia, pago_movil, zelle,
-- efectivo), pero no hay FK. Añadir un método nuevo requiere ALTER TABLE.
-- Migrar a FK permite gestionar el catálogo sin tocar el esquema.
--
-- ALCANCE
-- 1. Añadir `pagos.id_metodo INT NULL`.
-- 2. Migrar los datos existentes mapeando el ENUM al `codigo` de
--    `metodos_pago`.
-- 3. Drop del ENUM `metodo_pago`.
-- 4. FK + índice.
-- 5. Fix colateral: `v_facturas_con_saldo` con GREATEST (DB-15).
--
-- ROLLBACK
--   ALTER TABLE pagos DROP FOREIGN KEY fk_pago_metodo;
--   ALTER TABLE pagos DROP INDEX idx_pago_metodo;
--   ALTER TABLE pagos DROP COLUMN id_metodo;
--   ALTER TABLE pagos
--     ADD COLUMN metodo_pago ENUM('transferencia','pago_movil','zelle','efectivo') DEFAULT NULL AFTER fecha_pago;
--   -- Repoblar el ENUM desde metodos_pago:
--   UPDATE pagos p INNER JOIN metodos_pago mp ON mp.id_metodo = p.id_metodo
--     SET p.metodo_pago = mp.codigo;
--   -- Recrear la vista sin GREATEST (definición previa):
--   CREATE OR REPLACE VIEW v_facturas_con_saldo AS ...;
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- PASO 1 — Añadir id_metodo
-- =================================================================

ALTER TABLE pagos
  ADD COLUMN id_metodo INT(11) DEFAULT NULL AFTER fecha_pago;

-- =================================================================
-- PASO 2 — Migrar datos: mapear ENUM → codigo de metodos_pago
-- =================================================================

UPDATE pagos p
INNER JOIN metodos_pago mp ON mp.codigo = p.metodo_pago
SET p.id_metodo = mp.id_metodo
WHERE p.metodo_pago IS NOT NULL;

-- =================================================================
-- PASO 3 — Diagnóstico previo al DROP
-- =================================================================
-- Debe devolver 0 filas. Si devuelve >0, ABORTAR.

SELECT p.id_pago, p.metodo_pago, p.id_metodo
FROM pagos p
WHERE p.metodo_pago IS NOT NULL AND p.id_metodo IS NULL;

-- =================================================================
-- PASO 4 — Drop del ENUM
-- =================================================================

ALTER TABLE pagos DROP COLUMN metodo_pago;

-- =================================================================
-- PASO 5 — FK + índice
-- =================================================================

ALTER TABLE pagos
  ADD INDEX idx_pago_metodo (id_metodo),
  ADD CONSTRAINT fk_pago_metodo
    FOREIGN KEY (id_metodo) REFERENCES metodos_pago (id_metodo)
    ON DELETE RESTRICT ON UPDATE RESTRICT;

-- =================================================================
-- PASO 6 — Fix DB-15: v_facturas_con_saldo con GREATEST
-- =================================================================

CREATE OR REPLACE VIEW v_facturas_con_saldo AS
SELECT
  f.id_factura,
  f.id_servicio,
  f.periodo,
  f.monto,
  f.fecha_emision,
  f.fecha_vencimiento,
  f.estado,
  COALESCE(
    (SELECT SUM(monto) FROM pagos WHERE id_factura = f.id_factura AND estado = 'validado'),
    0
  ) AS total_pagado,
  GREATEST(
    f.monto - COALESCE(
      (SELECT SUM(monto) FROM pagos WHERE id_factura = f.id_factura AND estado = 'validado'),
      0
    ),
    0
  ) AS saldo,
  s.alias AS servicio_alias,
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
  c.cedula
FROM facturas f
INNER JOIN servicios s ON s.id_servicio = f.id_servicio
INNER JOIN clientes c ON c.id_cliente = s.id_cliente
WHERE f.estado IN ('pendiente','parcial','vencida');

-- =================================================================
-- VERIFICACIÓN FINAL
-- =================================================================

-- 1. Confirmar que metodo_pago ya no existe y id_metodo sí:
SHOW COLUMNS FROM pagos LIKE 'metodo_pago';
SHOW COLUMNS FROM pagos LIKE 'id_metodo';

-- 2. Confirmar la FK:
SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'bd_redytelca'
  AND TABLE_NAME = 'pagos'
  AND CONSTRAINT_NAME = 'fk_pago_metodo';

-- 3. Confirmar que los 4 pagos históricos tienen id_metodo:
SELECT p.id_pago, p.fecha_pago, p.id_metodo, mp.codigo, mp.nombre
FROM pagos p
LEFT JOIN metodos_pago mp ON mp.id_metodo = p.id_metodo
ORDER BY p.id_pago;

-- 4. Confirmar que la vista usa GREATEST:
SELECT saldo FROM v_facturas_con_saldo LIMIT 3;

-- =================================================================
-- Fin P15.
-- =================================================================