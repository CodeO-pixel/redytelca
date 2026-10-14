<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'usuarios');
requireOperation($pdo, 'usuarios', 'leer');

$query = "
    SELECT u.id_usuario, u.username, u.email, u.must_change_password, u.email_verified, u.estado,
           (SELECT MAX(creado_en) FROM sesiones WHERE id_usuario = u.id_usuario) AS ultima_conexion
    FROM usuarios u
    ORDER BY u.username ASC
";

$stmt = $pdo->query($query);
$usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Cargar los roles de cada usuario desde usuario_rol
$stmtRoles = $pdo->prepare("
    SELECT ur.id_usuario, r.id_rol, r.nombre_rol
    FROM usuario_rol ur
    INNER JOIN rol r ON r.id_rol = ur.id_rol
    ORDER BY r.id_rol
");
$stmtRoles->execute();
$rolesPorUsuario = [];
foreach ($stmtRoles->fetchAll(PDO::FETCH_ASSOC) as $row) {
    $idU = (int) $row['id_usuario'];
    if (!isset($rolesPorUsuario[$idU])) {
        $rolesPorUsuario[$idU] = [];
    }
    $rolesPorUsuario[$idU][] = [
        'id_rol' => (int) $row['id_rol'],
        'nombre_rol' => $row['nombre_rol'],
    ];
}

foreach ($usuarios as &$u) {
    $idU = (int) $u['id_usuario'];
    $u['roles'] = $rolesPorUsuario[$idU] ?? [];
    $u['roles_ids'] = array_column($u['roles'], 'id_rol');
    $u['roles_nombres'] = implode(', ', array_column($u['roles'], 'nombre_rol'));
    $u['es_admin'] = in_array(1, $u['roles_ids'], true);
}
unset($u);

echo json_encode([
    'status' => 'success',
    'usuarios' => $usuarios
]);