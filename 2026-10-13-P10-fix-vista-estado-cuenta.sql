-- =================================================================
-- P10 — Fix: cálculo de `saldo_pendiente` en v_estado_cuenta_cliente
-- Fecha: 2026-10-13
-- Autorizado por: hallazgo operativo (ver MEMORY.md)
--
-- MOTIVO DEL CAMBIO
-- La definición anterior sumaba el monto COMPLETO de las facturas en
-- estado 'pendiente', 'parcial' o 'vencida', sin restar los pagos ya
-- validados. Para una factura 'parcial' (ej. monto=100, un pago de 40),
-- la vista reportaba saldo_pendiente=100 en lugar de 60. El saldo real
-- de un cliente es: SUM(monto facturado) − SUM(pagos validados),
-- limitado inferiormente a 0 por factura para evitar saldos negativos
-- en caso de sobrepago.
--
-- IMPLEMENTACIÓN
-- Se añade un LEFT JOIN a una subquery que pre-agrupa los pagos con
-- estado='validado' por id_factura, y se sustituye la suma directa del
-- monto por GREATEST(f.monto − pagos_validados, 0). El resto de columnas
-- (facturas_vencidas, facturas_pagadas, ultima_fecha_vencimiento) y el
-- GROUP BY se conservan idénticos.
--
-- ROLLBACK
-- Restaurar la definición previa de la vista (suma directa de f.monto
-- para facturas en estado pendiente/parcial/vencida).
-- =================================================================

USE bd_redytelca;

CREATE OR REPLACE VIEW v_estado_cuenta_cliente AS
SELECT
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
  c.cedula,
  c.correo,
  c.num_telefono,
  COALESCE(SUM(
    CASE
      WHEN f.estado IN ('pendiente','parcial','vencida')
        THEN GREATEST(f.monto - COALESCE(pv.total_pagado, 0), 0)
      ELSE 0
    END
  ), 0) AS saldo_pendiente,
  COUNT(DISTINCT CASE WHEN f.estado = 'vencida' THEN f.id_factura END) AS facturas_vencidas,
  COUNT(DISTINCT CASE WHEN f.estado = 'pagada' THEN f.id_factura END) AS facturas_pagadas,
  MAX(f.fecha_vencimiento) AS ultima_fecha_vencimiento
FROM clientes c
LEFT JOIN servicios s ON s.id_cliente = c.id_cliente
LEFT JOIN facturas f ON f.id_servicio = s.id_servicio
LEFT JOIN (
  SELECT id_factura, SUM(monto) AS total_pagado
  FROM pagos
  WHERE estado = 'validado'
  GROUP BY id_factura
) pv ON pv.id_factura = f.id_factura
GROUP BY c.id_cliente, c.nombres, c.apellidos, c.cedula, c.correo, c.num_telefono;

-- =================================================================
-- VERIFICACIÓN
-- Devuelve los primeros 5 clientes con su saldo calculado. Comparar
-- con los valores previos al cambio: para clientes con facturas en
-- estado 'parcial' con pagos validados, el saldo_pendiente debe ser
-- menor (monto − pagos) en lugar del monto completo.
-- =================================================================

SELECT id_cliente, cliente, saldo_pendiente, facturas_vencidas, facturas_pagadas
FROM v_estado_cuenta_cliente
ORDER BY id_cliente
LIMIT 5;

-- =================================================================
-- Fin P10.
-- =================================================================