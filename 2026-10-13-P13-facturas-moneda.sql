-- =================================================================
-- P13 — Añadir moneda y tasa_cambio a facturas
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO
-- La tabla `pagos` ya tiene `moneda_pago` + `tasa_cambio` para
-- registrar en qué moneda se pagó y con qué tasa BCV. La tabla
-- `facturas`, sin embargo, no tenía esos campos, lo que crea una
-- asimetría imposible de resolver en reportes: una factura emitida
-- en VES no podía diferenciarse de una en USD, y no había forma
-- de reconstruir la tasa aplicada en el momento de la emisión.
--
-- CAMBIO
-- Aditivo, no destructivo. Se añaden dos columnas:
--   moneda       VARCHAR(3)      NOT NULL DEFAULT 'USD'
--   tasa_cambio  DECIMAL(10,4)   NULL
--
-- Se añaden dos CHECK para reforzar las invariantes del dominio:
--   - moneda solo puede ser 'USD' o 'VES'.
--   - tasa_cambio, si existe, debe ser positiva (una tasa 0 o
--     negativa no tiene sentido financiero).
--
-- Las facturas existentes quedan automáticamente con moneda='USD'
-- y tasa_cambio=NULL por el DEFAULT. No hay migración de datos.
--
-- ROLLBACK
--   ALTER TABLE facturas
--     DROP CONSTRAINT chk_factura_tasa,
--     DROP CONSTRAINT chk_factura_moneda,
--     DROP COLUMN tasa_cambio,
--     DROP COLUMN moneda;
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- BLOQUE ÚNICO — ALTER TABLE facturas
-- =================================================================

ALTER TABLE facturas
  ADD COLUMN moneda VARCHAR(3) NOT NULL DEFAULT 'USD' AFTER monto,
  ADD COLUMN tasa_cambio DECIMAL(10,4) DEFAULT NULL AFTER moneda,
  ADD CONSTRAINT chk_factura_moneda CHECK (moneda IN ('USD', 'VES')),
  ADD CONSTRAINT chk_factura_tasa CHECK (tasa_cambio IS NULL OR tasa_cambio > 0);

-- =================================================================
-- VERIFICACIÓN FINAL
-- Debe mostrar moneda='USD' y tasa_cambio=NULL en las 5 filas
-- (valores por defecto aplicados retroactivamente).
-- =================================================================

SELECT id_factura, periodo, monto, moneda, tasa_cambio, estado
FROM facturas ORDER BY id_factura LIMIT 5;

-- =================================================================
-- Fin P13.
-- =================================================================