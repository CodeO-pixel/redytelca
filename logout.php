<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';

$token = '';
if (isset($_SERVER['HTTP_X_SESSION_TOKEN']) && trim($_SERVER['HTTP_X_SESSION_TOKEN']) !== '') {
    $token = trim($_SERVER['HTTP_X_SESSION_TOKEN']);
}

if ($token !== '') {
    try {
        $stmt = $pdo->prepare("UPDATE sesiones SET expira_en = UTC_TIMESTAMP(), revocado_en = UTC_TIMESTAMP(), motivo_cierre = 'logout' WHERE token = ?");
        $stmt->execute([$token]);
    } catch (Exception $e) {
        // Ignorar error en logout
    }
}

echo json_encode(['status' => 'success']);