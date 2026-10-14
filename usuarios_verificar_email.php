<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'usuarios');
$staffSession = requireOperation($pdo, 'usuarios', 'editar');

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
$data = $_POST;
}

$idUsuario = isset($data['id_usuario']) ? intval($data['id_usuario']) : 0;

if ($idUsuario <= 0) {
echo json_encode(['status' => 'error', 'message' => 'ID de usuario inválido']);
exit;
}

try {
$stmt = $pdo->prepare('UPDATE usuarios SET email_verified = 1 WHERE id_usuario = ?');
$ok = $stmt->execute([$idUsuario]);

echo json_encode([
'status' => $ok ? 'success' : 'error',
'message' => $ok ? 'Correo verificado correctamente.' : 'No se pudo actualizar el estado de verificación.'
]);
} catch (Exception $e) {
http_response_code(500);
echo json_encode(['status' => 'error', 'message' => 'Error interno al verificar el correo.']);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'usuarios', 'editar'). Verificar un email
// es una edición del flag email_verified, no una creación. El acceso
// lo decide la matriz de permisos (rol_modulo_permiso) en lugar del id_rol.