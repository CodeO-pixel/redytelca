-- =================================================================
-- P13b — Opción B: documentar semántica de monto/moneda/tasa_cambio
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO
-- P13 añadió `moneda` y `tasa_cambio` a `facturas` para alinear la
-- tabla con `pagos` (que ya tenía `moneda_pago` + `tasa_cambio`).
-- Pero el esquema no documenta QUÉ significa cada columna. Esto
-- produce ambigüedad interpretativa: ¿el monto es en la moneda de
-- presentación o en USD? ¿la tasa se aplica antes o después del
-- monto? La ambigüedad ya generó confusión en el equipo y es la
-- clase de detalle que un jurado pregunta.
--
-- CONTEXTO DE NEGOCIO (Venezuela, ISPs)
-- La factura fiscal se emite en bolívares a la tasa BCV del día.
-- Los ISPs fijan los precios de sus planes en USD (catálogo), pero
-- presentan la factura en Bs. al cambio del día. El monto real del
-- catálogo sigue siendo en USD; la moneda de presentación solo
-- indica cómo se emite fiscalmente el documento. La tasa captura
-- el tipo de cambio aplicado para esa presentación.
--
-- SEMÁNTICA DEFINITIVA
--   monto / pagos.monto        = monto en USD (referencia de catálogo).
--                                SIEMPRE en USD, independiente de la
--                                moneda de presentación.
--   moneda / pagos.moneda_pago = divisa de presentación fiscal.
--                                'USD' = factura/pago en dólares.
--                                'VES' = factura/pago en bolívares al
--                                cambio BCV.
--   tasa_cambio                = tasa BCV (Bs/USD) del día. Obligatoria
--                                si la moneda es VES, NULL si es USD.
--
-- CAMBIO
-- Solo COMMENTs. No hay cambios de tipo, NULL/NOT NULL, DEFAULT ni
-- datos. Los datos existentes no se tocan. Los CHECK existentes
-- (chk_factura_moneda, chk_factura_tasa, chk_pago_monto, chk_pago_tasa,
-- chk_pago_metodo) se preservan: MODIFY COLUMN no los elimina.
--
-- ROLLBACK
--   ALTER TABLE facturas
--     MODIFY COLUMN monto DECIMAL(10,2) NOT NULL,
--     MODIFY COLUMN moneda VARCHAR(3) NOT NULL DEFAULT 'USD',
--     MODIFY COLUMN tasa_cambio DECIMAL(10,4) DEFAULT NULL;
--   ALTER TABLE pagos
--     MODIFY COLUMN monto DECIMAL(10,2) NOT NULL,
--     MODIFY COLUMN moneda_pago ENUM('USD','VES') NOT NULL DEFAULT 'USD',
--     MODIFY COLUMN tasa_cambio DECIMAL(10,4) DEFAULT NULL COMMENT 'Tasa BCV al momento del pago';
--   (el COMMENT original de pagos.tasa_cambio se restaura explícitamente)
-- =================================================================

USE bd_redytelca;

-- =================================================================
-- BLOQUE 1 — facturas
-- =================================================================

ALTER TABLE facturas
  MODIFY COLUMN monto DECIMAL(10,2) NOT NULL COMMENT 'Monto en USD (precio de referencia del catálogo). Independiente de la moneda de presentación.',
  MODIFY COLUMN moneda VARCHAR(3) NOT NULL DEFAULT 'USD' COMMENT 'Divisa de presentación fiscal. USD = factura en dólares; VES = factura en bolívares al cambio BCV.',
  MODIFY COLUMN tasa_cambio DECIMAL(10,4) DEFAULT NULL COMMENT 'Tasa BCV (Bs/USD) al momento de emisión. Obligatoria si moneda=VES, NULL si moneda=USD.';

-- =================================================================
-- BLOQUE 2 — pagos
-- =================================================================

ALTER TABLE pagos
  MODIFY COLUMN monto DECIMAL(10,2) NOT NULL COMMENT 'Monto en USD (precio de referencia). Independiente de la moneda_pago.',
  MODIFY COLUMN moneda_pago ENUM('USD','VES') NOT NULL DEFAULT 'USD' COMMENT 'Divisa en la que se realizó el pago. USD = pago en dólares; VES = pago en bolívares.',
  MODIFY COLUMN tasa_cambio DECIMAL(10,4) DEFAULT NULL COMMENT 'Tasa BCV (Bs/USD) del día del pago. Obligatoria si moneda_pago=VES, NULL si moneda_pago=USD.';

-- =================================================================
-- VERIFICACIÓN
-- Debe mostrar los Comment nuevos en ambas tablas.
-- =================================================================

SHOW FULL COLUMNS FROM facturas WHERE Field IN ('monto','moneda','tasa_cambio');
SHOW FULL COLUMNS FROM pagos WHERE Field IN ('monto','moneda_pago','tasa_cambio');

-- =================================================================
-- Fin P13b.
-- =================================================================