<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'facturas');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);
    exit;
}

try {
    $stmt = $pdo->exec("UPDATE facturas SET estado = 'vencida' WHERE estado = 'pendiente' AND fecha_vencimiento < CURDATE()");
    echo json_encode(['status' => 'success', 'actualizadas' => $stmt]);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error materializando vencimientos.']);
}