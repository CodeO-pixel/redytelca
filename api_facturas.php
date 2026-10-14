<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'facturas');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
requireOperation($pdo, 'facturas', 'leer');
$stmt = $pdo->query("SELECT f.*,
s.alias AS servicio_alias, s.direccion_texto,
c.id_cliente, c.nombres, c.apellidos, c.cedula,
pl.nombre AS plan_nombre,
(SELECT COALESCE(SUM(pg.monto), 0) FROM pagos pg
WHERE pg.id_factura = f.id_factura AND pg.estado = 'validado') AS total_pagado
FROM facturas f
INNER JOIN servicios s ON s.id_servicio = f.id_servicio
INNER JOIN clientes c ON c.id_cliente = s.id_cliente
LEFT JOIN planes pl ON pl.id_plan = s.id_plan
ORDER BY f.fecha_vencimiento DESC");
echo json_encode(['status' => 'success', 'facturas' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

if ($method === 'POST') {
requireOperation($pdo, 'facturas', 'crear');
$id_servicio = (int)($input['id_servicio'] ?? 0);
$periodo = trim($input['periodo'] ?? '');
$monto = isset($input['monto']) && $input['monto'] !== '' ? (float)$input['monto'] : null;
$fecha_emision = trim($input['fecha_emision'] ?? '');
$fecha_vencimiento = trim($input['fecha_vencimiento'] ?? '');
$estado = trim($input['estado'] ?? 'pendiente');

$impuesto_aplicado = isset($input['impuesto_aplicado']) && $input['impuesto_aplicado'] !== '' ? (float)$input['impuesto_aplicado'] : 0.00;

if ($id_servicio <= 0 || $periodo === '' || $monto === null || $monto <= 0 || $fecha_emision === '' || $fecha_vencimiento === '') {
echo json_encode(['status' => 'error', 'message' => 'Servicio, periodo, monto, fecha de emisión y fecha de vencimiento son obligatorios']);
exit;
}

if (!preg_match('/^\d{4}-\d{2}$/', $periodo)) {
echo json_encode(['status' => 'error', 'message' => 'El periodo debe tener el formato AAAA-MM (ej. 2026-07)']);
exit;
}

$estadosValidos = ['pendiente', 'pagada', 'parcial', 'vencida', 'anulada'];
if (!in_array($estado, $estadosValidos, true)) {
$estado = 'pendiente';
}

$moneda = trim($input['moneda'] ?? 'USD');
if (!in_array($moneda, ['USD', 'VES'], true)) { $moneda = 'USD'; }
$tasa_cambio = isset($input['tasa_cambio']) && $input['tasa_cambio'] !== '' ? (float)$input['tasa_cambio'] : null;
if ($moneda === 'VES' && ($tasa_cambio === null || $tasa_cambio <= 0)) {
    echo json_encode(['status' => 'error', 'message' => 'Si la moneda es VES, la tasa de cambio es obligatoria y debe ser mayor a 0.']);
    exit;
}
if ($moneda === 'USD') { $tasa_cambio = null; }

try {
$stmt = $pdo->prepare("INSERT INTO facturas (id_servicio, periodo, monto, moneda, tasa_cambio, fecha_emision, fecha_vencimiento, estado, impuesto_aplicado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
$ok = $stmt->execute([$id_servicio, $periodo, $monto, $moneda, $tasa_cambio, $fecha_emision, $fecha_vencimiento, $estado, $impuesto_aplicado]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Factura creada correctamente' : 'No se pudo crear la factura']);
} catch (PDOException $e) {
$sqlCode = (int) ($e->errorInfo[1] ?? 0);
if ($sqlCode === 1452) {
echo json_encode(['status' => 'error', 'message' => 'El servicio seleccionado no existe o fue eliminado.']);
} elseif ($sqlCode === 1062) {
echo json_encode(['status' => 'error', 'message' => 'Ya existe una factura para ese servicio en ese periodo.']);
} else {
echo json_encode(['status' => 'error', 'message' => 'Error creando la factura. Contacta al administrador si persiste.']);
}
}
exit;
}

if ($method === 'PUT') {
requireOperation($pdo, 'facturas', 'editar');
$id = (int)($input['id_factura'] ?? 0);
if ($id <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Factura inválida']);
exit;
}

$id_servicio = (int)($input['id_servicio'] ?? 0);
$periodo = trim($input['periodo'] ?? '');
$monto = isset($input['monto']) && $input['monto'] !== '' ? (float)$input['monto'] : null;
$fecha_emision = trim($input['fecha_emision'] ?? '');
$fecha_vencimiento = trim($input['fecha_vencimiento'] ?? '');
$estado = trim($input['estado'] ?? 'pendiente');
$impuesto_aplicado = isset($input['impuesto_aplicado']) && $input['impuesto_aplicado'] !== '' ? (float)$input['impuesto_aplicado'] : 0.00;

if ($id_servicio <= 0 || $periodo === '' || $monto === null || $monto <= 0 || $fecha_emision === '' || $fecha_vencimiento === '') {
echo json_encode(['status' => 'error', 'message' => 'Servicio, periodo, monto, fecha de emisión y fecha de vencimiento son obligatorios']);
exit;
}

if (!preg_match('/^\d{4}-\d{2}$/', $periodo)) {
echo json_encode(['status' => 'error', 'message' => 'El periodo debe tener el formato AAAA-MM (ej. 2026-07)']);
exit;
}

$estadosValidos = ['pendiente', 'pagada', 'parcial', 'vencida', 'anulada'];
if (!in_array($estado, $estadosValidos, true)) {
$estado = 'pendiente';
}

$moneda = trim($input['moneda'] ?? 'USD');
if (!in_array($moneda, ['USD', 'VES'], true)) { $moneda = 'USD'; }
$tasa_cambio = isset($input['tasa_cambio']) && $input['tasa_cambio'] !== '' ? (float)$input['tasa_cambio'] : null;
if ($moneda === 'VES' && ($tasa_cambio === null || $tasa_cambio <= 0)) {
    echo json_encode(['status' => 'error', 'message' => 'Si la moneda es VES, la tasa de cambio es obligatoria y debe ser mayor a 0.']);
    exit;
}
if ($moneda === 'USD') { $tasa_cambio = null; }

$stmtExists = $pdo->prepare("SELECT COUNT(*) FROM facturas WHERE id_factura = ?");
$stmtExists->execute([$id]);
if ((int) $stmtExists->fetchColumn() === 0) {
http_response_code(404);
echo json_encode(['status' => 'error', 'message' => 'Factura no encontrada.']);
exit;
}

try {
$stmt = $pdo->prepare("UPDATE facturas SET id_servicio = ?, periodo = ?, monto = ?, moneda = ?, tasa_cambio = ?, fecha_emision = ?, fecha_vencimiento = ?, estado = ?, impuesto_aplicado = ? WHERE id_factura = ?");
$ok = $stmt->execute([$id_servicio, $periodo, $monto, $moneda, $tasa_cambio, $fecha_emision, $fecha_vencimiento, $estado, $impuesto_aplicado, $id]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Factura actualizada' : 'No se pudo actualizar']);
} catch (PDOException $e) {
$sqlCode = (int) ($e->errorInfo[1] ?? 0);
if ($sqlCode === 1452) {
echo json_encode(['status' => 'error', 'message' => 'El servicio seleccionado no existe o fue eliminado.']);
} elseif ($sqlCode === 1062) {
http_response_code(409);
echo json_encode(['status' => 'error', 'message' => 'Ya existe una factura para ese servicio en ese periodo.']);
} elseif ($sqlCode === 1644) {
echo json_encode(['status' => 'error', 'message' => $e->errorInfo[2] ?: 'La transición de estado no es válida para esta factura.']);
} else {
echo json_encode(['status' => 'error', 'message' => 'Error actualizando la factura. Contacta al administrador si persiste.']);
}
}
exit;
}

if ($method === 'DELETE') {
requireOperation($pdo, 'facturas', 'eliminar');
$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Factura inválida']);
exit;
}

// No se permite DELETE físico si ya hay pagos asociados: rompería la
// trazabilidad contable. La vía correcta para "cancelar" una factura
// con historial es transicionarla a estado 'anulada' vía PUT.
$stmtCheck = $pdo->prepare("SELECT COUNT(*) FROM pagos WHERE id_factura = ?");
$stmtCheck->execute([$id]);
if ((int) $stmtCheck->fetchColumn() > 0) {
echo json_encode(['status' => 'error', 'message' => 'No se puede eliminar: esta factura tiene pagos asociados. Anúlala en vez de eliminarla, o reasigna los pagos primero.']);
exit;
}

try {
$stmt = $pdo->prepare("DELETE FROM facturas WHERE id_factura = ?");
$ok = $stmt->execute([$id]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Factura eliminada' : 'No se pudo eliminar']);
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'No se pudo eliminar la factura: ' . $e->getMessage()]);
}
exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);