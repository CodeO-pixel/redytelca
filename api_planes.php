<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'planes');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    requireOperation($pdo, 'planes', 'leer');
    // total_servicios permite que la UI advierta antes de un DELETE que
    // rompería integridad referencial, igual que total_naps en api_olts.php.
    // SELECT p.* expone automáticamente las columnas nuevas
    // velocidad_bajada_mbps, velocidad_subida_mbps y tecnologia.
    $stmt = $pdo->query("SELECT p.*,
                                (SELECT COUNT(*) FROM servicios s WHERE s.id_plan = p.id_plan) AS total_servicios
                         FROM planes p
                         ORDER BY p.precio_mensual ASC");
    echo json_encode(['status' => 'success', 'planes' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

if ($method === 'POST') {
    requireOperation($pdo, 'planes', 'crear');
    $nombre = trim($input['nombre'] ?? '');
    $velocidad_bajada = isset($input['velocidad_bajada_mbps']) && $input['velocidad_bajada_mbps'] !== '' ? (float)$input['velocidad_bajada_mbps'] : null;
    $velocidad_subida = isset($input['velocidad_subida_mbps']) && $input['velocidad_subida_mbps'] !== '' ? (float)$input['velocidad_subida_mbps'] : null;
    $tecnologia = trim($input['tecnologia'] ?? 'FTTH');
    if (!in_array($tecnologia, ['FTTH','HFC','WISP','OTRO'], true)) { $tecnologia = 'FTTH'; }
    $precio_mensual = isset($input['precio_mensual']) && $input['precio_mensual'] !== '' ? (float)$input['precio_mensual'] : null;
    $moneda = trim($input['moneda'] ?? 'USD');
    $estado = trim($input['estado'] ?? 'activo');
    if (!in_array($estado, ['activo', 'inactivo'], true)) {
        $estado = 'activo';
    }

    if ($nombre === '' || $velocidad_bajada === null || $precio_mensual === null || $precio_mensual <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Nombre, velocidad y precio mensual son obligatorios']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("INSERT INTO planes (nombre, velocidad_bajada_mbps, velocidad_subida_mbps, tecnologia, precio_mensual, moneda, estado) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $ok = $stmt->execute([$nombre, $velocidad_bajada, $velocidad_subida, $tecnologia, $precio_mensual, $moneda ?: 'USD', $estado]);
        echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Plan creado correctamente' : 'No se pudo crear el plan']);    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Error creando el plan. Contacta al administrador si persiste.']);    }
    exit;
}

if ($method === 'PUT') {
    requireOperation($pdo, 'planes', 'editar');
    $id = (int)($input['id_plan'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Plan inválido']);
        exit;
    }

    $nombre = trim($input['nombre'] ?? '');
    $velocidad_bajada = isset($input['velocidad_bajada_mbps']) && $input['velocidad_bajada_mbps'] !== '' ? (float)$input['velocidad_bajada_mbps'] : null;
    $velocidad_subida = isset($input['velocidad_subida_mbps']) && $input['velocidad_subida_mbps'] !== '' ? (float)$input['velocidad_subida_mbps'] : null;
    $tecnologia = trim($input['tecnologia'] ?? 'FTTH');
    if (!in_array($tecnologia, ['FTTH','HFC','WISP','OTRO'], true)) { $tecnologia = 'FTTH'; }
    $precio_mensual = isset($input['precio_mensual']) && $input['precio_mensual'] !== '' ? (float)$input['precio_mensual'] : null;
    $moneda = trim($input['moneda'] ?? 'USD');
    $estado = trim($input['estado'] ?? 'activo');
    if (!in_array($estado, ['activo', 'inactivo'], true)) {
        $estado = 'activo';
    }

    if ($nombre === '' || $velocidad_bajada === null || $precio_mensual === null || $precio_mensual <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Nombre, velocidad y precio mensual son obligatorios']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("UPDATE planes SET nombre = ?, velocidad_bajada_mbps = ?, velocidad_subida_mbps = ?, tecnologia = ?, precio_mensual = ?, moneda = ?, estado = ? WHERE id_plan = ?");
        $ok = $stmt->execute([$nombre, $velocidad_bajada, $velocidad_subida, $tecnologia, $precio_mensual, $moneda ?: 'USD', $estado, $id]);
        echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Plan actualizado' : 'No se pudo actualizar']);
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Error actualizando el plan. Contacta al administrador si persiste.']);    }
    exit;
}

if ($method === 'DELETE') {
    requireOperation($pdo, 'planes', 'eliminar');
    $id = (int)($_GET['id'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Plan inválido']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("DELETE FROM planes WHERE id_plan = ?");
        $ok = $stmt->execute([$id]);
        echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Plan eliminado' : 'No se pudo eliminar']);
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'No se puede eliminar: este plan tiene servicios asociados. Reasígnalos primero.']);
    }
    exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);