<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'contratos');

$method = $_SERVER['REQUEST_METHOD'];

/**
* CORRECCIÓN FASE 2.5: se añade sincronizarEstadoServicio(). Hallazgo de
* la auditoría: `contratos.estado` y `servicios.estado_comercial` son ejes
* distintos (legal vs. operativo) y NO son redundantes entre sí, pero
* hasta ahora no había ninguna regla que los mantuviera coherentes —
* podía existir un contrato 'rescindido' con un servicio que seguía en
* 'activo' porque nadie disparaba el cambio en cascada. Ahora, al
* transicionar un contrato a 'rescindido', su servicio pasa
* automáticamente a 'retirado'. Misma filosofía que reconciliarFactura()
* en api_pagos.php: lógica de negocio en capa de aplicación, no trigger.
*/

function sincronizarEstadoServicio(PDO $pdo, int $idServicio, string $estadoContrato): void {
if ($estadoContrato === 'rescindido') {
$stmt = $pdo->prepare("UPDATE servicios SET estado_comercial = 'retirado' WHERE id_servicio = ? AND estado_comercial <> 'retirado'");
$stmt->execute([$idServicio]);
}
}

if ($method === 'GET') {
requireOperation($pdo, 'contratos', 'leer');
$stmt = $pdo->query("SELECT ct.*,
s.alias AS servicio_alias, s.direccion_texto,
c.id_cliente, c.nombres, c.apellidos, c.cedula,
pl.nombre AS plan_nombre
FROM contratos ct
INNER JOIN servicios s ON s.id_servicio = ct.id_servicio
INNER JOIN clientes c ON c.id_cliente = s.id_cliente
LEFT JOIN planes pl ON pl.id_plan = s.id_plan
ORDER BY ct.fecha_inicio DESC");
echo json_encode(['status' => 'success', 'contratos' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

if ($method === 'POST') {
requireOperation($pdo, 'contratos', 'crear');
$id_servicio = (int)($input['id_servicio'] ?? 0);
$fecha_inicio = trim($input['fecha_inicio'] ?? '');
$fecha_fin = trim($input['fecha_fin'] ?? '');
$tipo_contrato = trim($input['tipo_contrato'] ?? 'indefinido');
$estado = trim($input['estado'] ?? 'vigente');
$observaciones = trim($input['observaciones'] ?? '');

if ($id_servicio <= 0 || $fecha_inicio === '') {
echo json_encode(['status' => 'error', 'message' => 'Servicio y fecha de inicio son obligatorios']);
exit;
}

$tiposValidos = ['indefinido', 'plazo_fijo', 'promocional'];
if (!in_array($tipo_contrato, $tiposValidos, true)) {
$tipo_contrato = 'indefinido';
}
if ($tipo_contrato !== 'indefinido' && $fecha_fin === '') {
echo json_encode(['status' => 'error', 'message' => 'Un contrato a plazo fijo o promocional requiere fecha de fin']);
exit;
}

// El trigger trg_contratos_validar_insert solo permite estado
// 'vigente' en INSERT. El resto de transiciones se hacen vía
// UPDATE. Cualquier valor recibido que no sea 'vigente' se
// normaliza a 'vigente' para no morir con SIGNAL 45000.
$estado = 'vigente';

$pdo->beginTransaction();
try {
$stmt = $pdo->prepare("INSERT INTO contratos (id_servicio, fecha_inicio, fecha_fin, tipo_contrato, estado, observaciones) VALUES (?, ?, ?, ?, ?, ?)");
$ok = $stmt->execute([$id_servicio, $fecha_inicio, $fecha_fin ?: null, $tipo_contrato, $estado, $observaciones ?: null]);

if ($ok) {
sincronizarEstadoServicio($pdo, $id_servicio, $estado);
}

$pdo->commit();
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Contrato creado correctamente' : 'No se pudo crear el contrato']);
} catch (PDOException $e) {
$pdo->rollBack();
$sqlCode = (int) ($e->errorInfo[1] ?? 0);
if ($sqlCode === 1452) {
echo json_encode(['status' => 'error', 'message' => 'El servicio seleccionado no existe o fue eliminado.']);
} elseif ($sqlCode === 1644) {
echo json_encode(['status' => 'error', 'message' => $e->errorInfo[2] ?: 'No se puede crear el contrato con esos datos.']);
} else {
echo json_encode(['status' => 'error', 'message' => 'Error creando el contrato. Contacta al administrador si persiste.']);
}
}
exit;
}

if ($method === 'PUT') {
requireOperation($pdo, 'contratos', 'editar');
$id = (int)($input['id_contrato'] ?? 0);
if ($id <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Contrato inválido']);
exit;
}

$id_servicio = (int)($input['id_servicio'] ?? 0);
$fecha_inicio = trim($input['fecha_inicio'] ?? '');
$fecha_fin = trim($input['fecha_fin'] ?? '');
$tipo_contrato = trim($input['tipo_contrato'] ?? 'indefinido');
$estado = trim($input['estado'] ?? 'vigente');
$observaciones = trim($input['observaciones'] ?? '');

if ($id_servicio <= 0 || $fecha_inicio === '') {
echo json_encode(['status' => 'error', 'message' => 'Servicio y fecha de inicio son obligatorios']);
exit;
}

$tiposValidos = ['indefinido', 'plazo_fijo', 'promocional'];
if (!in_array($tipo_contrato, $tiposValidos, true)) {
$tipo_contrato = 'indefinido';
}
if ($tipo_contrato !== 'indefinido' && $fecha_fin === '') {
echo json_encode(['status' => 'error', 'message' => 'Un contrato a plazo fijo o promocional requiere fecha de fin']);
exit;
}

$estadosValidos = ['vigente', 'vencido', 'rescindido'];
if (!in_array($estado, $estadosValidos, true)) {
$estado = 'vigente';
}

$stmtExists = $pdo->prepare("SELECT COUNT(*) FROM contratos WHERE id_contrato = ?");
$stmtExists->execute([$id]);
if ((int) $stmtExists->fetchColumn() === 0) {
http_response_code(404);
echo json_encode(['status' => 'error', 'message' => 'Contrato no encontrado.']);
exit;
}

$pdo->beginTransaction();
try {
$stmt = $pdo->prepare("UPDATE contratos SET id_servicio = ?, fecha_inicio = ?, fecha_fin = ?, tipo_contrato = ?, estado = ?, observaciones = ? WHERE id_contrato = ?");
$ok = $stmt->execute([$id_servicio, $fecha_inicio, $fecha_fin ?: null, $tipo_contrato, $estado, $observaciones ?: null, $id]);

if ($ok) {
sincronizarEstadoServicio($pdo, $id_servicio, $estado);
}

$pdo->commit();
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Contrato actualizado' : 'No se pudo actualizar']);
} catch (PDOException $e) {
$pdo->rollBack();
$sqlCode = (int) ($e->errorInfo[1] ?? 0);
if ($sqlCode === 1452) {
echo json_encode(['status' => 'error', 'message' => 'El servicio seleccionado no existe o fue eliminado.']);
} elseif ($sqlCode === 1644) {
echo json_encode(['status' => 'error', 'message' => $e->errorInfo[2] ?: 'La transición de estado no es válida para este contrato.']);
} else {
echo json_encode(['status' => 'error', 'message' => 'Error actualizando el contrato. Contacta al administrador si persiste.']);
}
}
exit;
}

if ($method === 'DELETE') {
requireOperation($pdo, 'contratos', 'eliminar');
$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Contrato inválido']);
exit;
}

try {
$stmt = $pdo->prepare("DELETE FROM contratos WHERE id_contrato = ?");
$ok = $stmt->execute([$id]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Contrato eliminado' : 'No se pudo eliminar']);
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'No se pudo eliminar el contrato: ' . $e->getMessage()]);
}
exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);