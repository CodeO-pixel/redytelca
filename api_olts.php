<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'olts');

$method = $_SERVER['REQUEST_METHOD'];
// Auto-reparación de esquema eliminada (Prompt 5): bd_redytelca.sql es la fuente de verdad desde Fase 0, este bloque siempre resolvía a no-op.

if ($method === 'GET') {
requireOperation($pdo, 'olts', 'leer');
$stmt = $pdo->query("SELECT o.*, n.nombre AS nombre_nodo,
(SELECT COUNT(*) FROM naps na WHERE na.id_olts = o.id_olt) AS total_naps
FROM olts o
LEFT JOIN nodos n ON n.id_nodo = o.id_nodos
ORDER BY o.id_olt ASC");
echo json_encode(['status' => 'success', 'olts' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

if ($method === 'POST') {
requireOperation($pdo, 'olts', 'crear');
$marca_modelo = trim($input['marca_modelo'] ?? '');
$puertos_pon = isset($input['puertos_pon']) && $input['puertos_pon'] !== '' ? (int)$input['puertos_pon'] : 16;
$ip_gestion = trim($input['ip_gestion'] ?? '');
$id_nodos = (int)($input['id_nodos'] ?? 0);
$codigo = trim($input['codigo'] ?? '');

if ($marca_modelo === '' || $id_nodos <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Marca/modelo y nodo son obligatorios']);
exit;
}

try {
$stmt = $pdo->prepare("INSERT INTO olts (marca_modelo, puertos_pon, ip_gestion, id_nodos, codigo) VALUES (?, ?, ?, ?, ?)");
$ok = $stmt->execute([$marca_modelo, $puertos_pon, $ip_gestion ?: null, $id_nodos, $codigo ?: null]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'OLT creada correctamente' : 'No se pudo crear la OLT']);
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'Error creando la OLT: el nodo seleccionado no existe o la IP ya está en uso']);
}
exit;
}

if ($method === 'PUT') {
requireOperation($pdo, 'olts', 'editar');
$id = (int)($input['id_olt'] ?? 0);
if ($id <= 0) {
echo json_encode(['status' => 'error', 'message' => 'OLT inválida']);
exit;
}

if (trim($input['marca_modelo'] ?? '') === '' || (int)($input['id_nodos'] ?? 0) <= 0) {
echo json_encode(['status' => 'error', 'message' => 'Marca/modelo y nodo son obligatorios.']);
exit;
}

$stmtExists = $pdo->prepare("SELECT COUNT(*) FROM olts WHERE id_olt = ?");
$stmtExists->execute([$id]);
if ((int) $stmtExists->fetchColumn() === 0) {
http_response_code(404);
echo json_encode(['status' => 'error', 'message' => 'OLT no encontrada.']);
exit;
}

try {
$stmt = $pdo->prepare("UPDATE olts SET marca_modelo = ?, puertos_pon = ?, ip_gestion = ?, id_nodos = ?, codigo = ? WHERE id_olt = ?");
$ok = $stmt->execute([
trim($input['marca_modelo'] ?? ''),
isset($input['puertos_pon']) && $input['puertos_pon'] !== '' ? (int)$input['puertos_pon'] : 16,
trim($input['ip_gestion'] ?? '') ?: null,
(int)($input['id_nodos'] ?? 0),
trim($input['codigo'] ?? '') ?: null,
$id
]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'OLT actualizada' : 'No se pudo actualizar']);
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'Error actualizando la OLT: verifica el nodo o la IP']);
}
exit;
}

if ($method === 'DELETE') {
requireOperation($pdo, 'olts', 'eliminar');
$id = (int)($_GET['id'] ?? 0);
try {
$stmt = $pdo->prepare("DELETE FROM olts WHERE id_olt = ?");
$ok = $stmt->execute([$id]);
echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'OLT eliminada' : 'No se pudo eliminar']);
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'No se puede eliminar: esta OLT tiene NAPs asociadas. Elimina o reasigna esas NAPs primero.']);
}
exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);