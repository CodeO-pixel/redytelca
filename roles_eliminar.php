<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'roles');
requireOperation($pdo, 'roles', 'eliminar');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

$idRol = isset($input['id_rol']) ? (int) $input['id_rol'] : (isset($_GET['id']) ? (int) $_GET['id'] : 0);

if ($idRol <= 0) {
echo json_encode(['status' => 'error', 'message' => 'No se recibió el identificador del rol']);
exit;
}

if ($idRol === 1) {
echo json_encode(['status' => 'error', 'message' => 'El rol Administrador no puede eliminarse: es la base del control de accesos del sistema.']);
exit;
}

$pdo->beginTransaction();
try {
$stmtExists = $pdo->prepare("SELECT id_rol FROM rol WHERE id_rol = ?");
$stmtExists->execute([$idRol]);
if (!$stmtExists->fetch()) {
$pdo->rollBack();
echo json_encode(['status' => 'error', 'message' => 'Este rol ya no existe (pudo haber sido eliminado por otra sesión).']);
exit;
}

// Contar usuarios con este rol en usuario_rol (N:M)
$stmtUsuariosConRol = $pdo->prepare("SELECT COUNT(DISTINCT id_usuario) FROM usuario_rol WHERE id_rol = ?");
$stmtUsuariosConRol->execute([$idRol]);
$totalUsuarios = (int) $stmtUsuariosConRol->fetchColumn();

if ($totalUsuarios > 0) {
$pdo->rollBack();
echo json_encode(['status' => 'error', 'message' => "No se puede eliminar: hay {$totalUsuarios} usuario(s) con este rol asignado. Reasígnalos a otro rol antes de eliminarlo."]);
exit;
}

// Obtener los id_rol_modulo asociados a este rol
$stmtRolModulos = $pdo->prepare("SELECT id_rol_modulo FROM rol_modulo WHERE id_rol = ?");
$stmtRolModulos->execute([$idRol]);
$idRolModulos = array_map('intval', $stmtRolModulos->fetchAll(PDO::FETCH_COLUMN, 0));

// Eliminar permisos asociados (rol_modulo_permiso)
if (!empty($idRolModulos)) {
$placeholders = implode(',', array_fill(0, count($idRolModulos), '?'));
$stmtDelPermisos = $pdo->prepare("DELETE FROM rol_modulo_permiso WHERE id_rol_modulo IN ($placeholders)");
$stmtDelPermisos->execute($idRolModulos);
}

// Eliminar asignaciones rol_modulo
$stmtDelRolModulo = $pdo->prepare("DELETE FROM rol_modulo WHERE id_rol = ?");
$stmtDelRolModulo->execute([$idRol]);

// Eliminar asignaciones usuario_rol (por consistencia, ya verificamos que está vacío)
$stmtDelUsuarioRol = $pdo->prepare("DELETE FROM usuario_rol WHERE id_rol = ?");
$stmtDelUsuarioRol->execute([$idRol]);

// Eliminar rol
$stmtDelRol = $pdo->prepare("DELETE FROM rol WHERE id_rol = ?");
$stmtDelRol->execute([$idRol]);
$ok = $stmtDelRol->rowCount() > 0;

$pdo->commit();
echo json_encode([
'status' => $ok ? 'success' : 'error',
'message' => $ok ? 'Rol eliminado correctamente' : 'No se pudo eliminar el rol'
]);
} catch (Exception $e) {
if ($pdo->inTransaction()) {
$pdo->rollBack();
}
echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el rol: ' . $e->getMessage()]);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'roles', 'eliminar'). La salvaguarda
// if ($idRol === 1) se conserva intacta porque es una regla de
// negocio (protección del rol Administrador), no un permiso de página.
// El bloqueo por usuarios asignados también se conserva.