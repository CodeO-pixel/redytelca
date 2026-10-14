<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'usuarios');
requireOperation($pdo, 'usuarios', 'eliminar');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

$idUsuario = isset($input['id_usuario']) ? (int) $input['id_usuario'] : 0;

if ($idUsuario <= 0) {
echo json_encode(['status' => 'error', 'message' => 'No se recibió el identificador del usuario.']);
exit;
}

$pdo->beginTransaction();
try {
$stmtCheck = $pdo->prepare("SELECT id_usuario FROM usuarios WHERE id_usuario = ?");
$stmtCheck->execute([$idUsuario]);
if (!$stmtCheck->fetch()) {
$pdo->rollBack();
echo json_encode(['status' => 'error', 'message' => 'Este usuario ya no existe (pudo haber sido eliminado por otra sesión).']);
exit;
}

$roles = loadUserRoles($pdo, $idUsuario);

// Salvaguarda: no eliminar al último Administrador.
if (in_array(1, $roles, true)) {
$stmtOtros = $pdo->prepare("
SELECT COUNT(DISTINCT ur.id_usuario)
FROM usuario_rol ur
INNER JOIN usuarios u ON u.id_usuario = ur.id_usuario
WHERE ur.id_rol = 1 AND ur.id_usuario <> ? AND u.estado = 'Activo'
");
$stmtOtros->execute([$idUsuario]);
if ((int) $stmtOtros->fetchColumn() === 0) {
$pdo->rollBack();
echo json_encode(['status' => 'error', 'message' => 'No puedes eliminar a este usuario: es el único administrador del sistema. Crea otro administrador antes de eliminarlo.']);
exit;
}
}

$stmtUnlinkTareas = $pdo->prepare("UPDATE tareas SET id_usuario_creador = NULL WHERE id_usuario_creador = ?");
$stmtUnlinkTareas->execute([$idUsuario]);

$stmtUnlinkTickets = $pdo->prepare("UPDATE tickets SET id_usuario_creador = NULL WHERE id_usuario_creador = ?");
$stmtUnlinkTickets->execute([$idUsuario]);

$stmtUnlinkPagos = $pdo->prepare("UPDATE pagos SET id_usuario_valido = NULL WHERE id_usuario_valido = ?");
$stmtUnlinkPagos->execute([$idUsuario]);

$stmtDelRoles = $pdo->prepare("DELETE FROM usuario_rol WHERE id_usuario = ?");
$stmtDelRoles->execute([$idUsuario]);

$stmtDelSesiones = $pdo->prepare("DELETE FROM sesiones WHERE id_usuario = ?");
$stmtDelSesiones->execute([$idUsuario]);

$stmtDelUsuario = $pdo->prepare("DELETE FROM usuarios WHERE id_usuario = ?");
$stmtDelUsuario->execute([$idUsuario]);
$ok = $stmtDelUsuario->rowCount() > 0;

$pdo->commit();
echo json_encode([
'status' => $ok ? 'success' : 'error',
'message' => $ok ? 'Usuario eliminado correctamente.' : 'No se pudo eliminar el usuario.'
]);
} catch (Exception $e) {
if ($pdo->inTransaction()) {
$pdo->rollBack();
}
echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el usuario: ' . $e->getMessage()]);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'usuarios', 'eliminar'). El acceso lo decide
// la matriz de permisos (rol_modulo_permiso) en lugar del id_rol.
// La salvaguarda del último Administrador se conserva intacta porque
// es una regla de negocio, no un permiso de página. La desvinculación
// de referencias (tareas, tickets, pagos) y el borrado de usuario_rol
// y sesiones también se conservan porque son parte del contrato de
// integridad del endpoint.