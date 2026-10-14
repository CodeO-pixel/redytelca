-- =================================================================
-- P6 — Refactor BD-COMPLETA: vistas
-- Fecha: 2026-10-13
-- Autorizado por: docs/ADR/013-bd-completa-refactor.md
-- Backup previo: C:\backups\bd_redytelca_20261012_pre-refactor.sql
-- Rollback: DROP VIEW de las 5 vistas.
-- =================================================================

-- 1. v_estado_cuenta_cliente
CREATE VIEW v_estado_cuenta_cliente AS
SELECT
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
  c.cedula,
  c.correo,
  c.num_telefono,
  COALESCE(SUM(CASE WHEN f.estado IN ('pendiente','parcial','vencida') THEN f.monto ELSE 0 END), 0) AS saldo_pendiente,
  COUNT(DISTINCT CASE WHEN f.estado = 'vencida' THEN f.id_factura END) AS facturas_vencidas,
  COUNT(DISTINCT CASE WHEN f.estado = 'pagada' THEN f.id_factura END) AS facturas_pagadas,
  MAX(f.fecha_vencimiento) AS ultima_fecha_vencimiento
FROM clientes c
LEFT JOIN servicios s ON s.id_cliente = c.id_cliente
LEFT JOIN facturas f ON f.id_servicio = s.id_servicio
GROUP BY c.id_cliente, c.nombres, c.apellidos, c.cedula, c.correo, c.num_telefono;

-- 2. v_clientes_360
CREATE VIEW v_clientes_360 AS
SELECT
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
  c.cedula,
  c.correo,
  c.num_telefono,
  c.fecha_registro,
  c.estado AS estado_cliente,
  c.segmento,
  (SELECT COUNT(*) FROM servicios s WHERE s.id_cliente = c.id_cliente AND s.estado_comercial <> 'retirado') AS servicios_activos,
  (SELECT COUNT(*) FROM tickets t WHERE t.id_cliente = c.id_cliente AND t.estado <> 'Cerrado') AS tickets_abiertos,
  (SELECT COUNT(*) FROM facturas f INNER JOIN servicios s2 ON s2.id_servicio = f.id_servicio
    WHERE s2.id_cliente = c.id_cliente AND f.estado = 'vencida') AS facturas_vencidas,
  (SELECT MAX(cc.ultimo_acceso) FROM clientes_credenciales cc WHERE cc.id_cliente = c.id_cliente) AS ultima_actividad
FROM clientes c;

-- 3. v_equipos_asignados
CREATE VIEW v_equipos_asignados AS
SELECT
  eq.id_equipo,
  eq.tipo,
  eq.marca,
  eq.modelo,
  eq.direccion_mac,
  eq.num_puerto_nap,
  eq.estado_fisico,
  eq.estado_inventario,
  eq.propiedad,
  na.codigo AS nap_codigo,
  o.codigo AS olt_codigo,
  n.nombre AS nodo_nombre,
  s.id_servicio,
  s.alias AS servicio_alias,
  s.direccion_texto,
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente
FROM equipos eq
INNER JOIN naps na ON na.id_nap = eq.id_naps
LEFT JOIN olts o ON o.id_olt = na.id_olts
LEFT JOIN nodos n ON n.id_nodo = o.id_nodos
LEFT JOIN servicios s ON s.id_servicio = eq.id_servicio
LEFT JOIN clientes c ON c.id_cliente = s.id_cliente
WHERE eq.estado_inventario = 'asignado' AND eq.id_servicio IS NOT NULL;

-- 4. v_ip_asignadas
CREATE VIEW v_ip_asignadas AS
SELECT
  ia.id_asignacion,
  ia.ip,
  ia.tipo,
  ia.estado,
  ia.asignada_en,
  ia.liberada_en,
  ip.nombre AS pool_nombre,
  ip.cidr AS pool_cidr,
  ip.vlan,
  s.id_servicio,
  s.alias AS servicio_alias,
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente
FROM ip_asignaciones ia
INNER JOIN ip_pools ip ON ip.id_pool = ia.id_pool
INNER JOIN servicios s ON s.id_servicio = ia.id_servicio
INNER JOIN clientes c ON c.id_cliente = s.id_cliente
WHERE ia.estado = 'activa';

-- 5. v_facturas_con_saldo
CREATE VIEW v_facturas_con_saldo AS
SELECT
  f.id_factura,
  f.id_servicio,
  f.periodo,
  f.monto,
  f.fecha_emision,
  f.fecha_vencimiento,
  f.estado,
  COALESCE((SELECT SUM(monto) FROM pagos WHERE id_factura = f.id_factura AND estado = 'validado'), 0) AS total_pagado,
  f.monto - COALESCE((SELECT SUM(monto) FROM pagos WHERE id_factura = f.id_factura AND estado = 'validado'), 0) AS saldo,
  s.alias AS servicio_alias,
  c.id_cliente,
  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
  c.cedula
FROM facturas f
INNER JOIN servicios s ON s.id_servicio = f.id_servicio
INNER JOIN clientes c ON c.id_cliente = s.id_cliente
WHERE f.estado IN ('pendiente','parcial','vencida');

-- =================================================================
-- Fin P6.
-- =================================================================