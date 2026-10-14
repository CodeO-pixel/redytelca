<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'contratos');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);
    exit;
}

try {
    $stmt = $pdo->exec("UPDATE contratos SET estado = 'vencido' WHERE estado = 'vigente' AND fecha_fin IS NOT NULL AND fecha_fin < CURDATE()");
    echo json_encode(['status' => 'success', 'actualizados' => $stmt]);
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error materializando vencimientos.']);
}