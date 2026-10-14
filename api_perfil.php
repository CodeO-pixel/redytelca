<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';

$staffSession = requireStaffAuth($pdo);
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $idUsuario = (int) $staffSession['id_usuario'];

    $stmtUser = $pdo->prepare("SELECT u.id_usuario, u.username, u.email
                                FROM usuarios u
                                WHERE u.id_usuario = ?");
    $stmtUser->execute([$idUsuario]);
    $user = $stmtUser->fetch(PDO::FETCH_ASSOC);

    $rolesNombres = loadUserRoleNames($pdo, $idUsuario);
    $user['nombre_rol'] = !empty($rolesNombres) ? implode(', ', $rolesNombres) : 'Sin rol';

    $stmtSesiones = $pdo->prepare("SELECT id_sesion, creado_en, expira_en
                                   FROM sesiones
                                   WHERE id_usuario = ?
                                   ORDER BY creado_en DESC
                                   LIMIT 20");
    $stmtSesiones->execute([$idUsuario]);
    $sesiones = $stmtSesiones->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'usuario' => $user,
        'sesiones' => $sesiones
    ]);
    exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);