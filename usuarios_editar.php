<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'usuarios');
requireOperation($pdo, 'usuarios', 'editar');

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

$idUsuario = isset($input['id_usuario']) ? (int) $input['id_usuario'] : 0;
$username = trim($input['username'] ?? '');
$email = trim($input['email'] ?? '');

// Aceptamos "id_rol" escalar (retrocompat) o "roles" array (nuevo).
$rolesRaw = [];
if (isset($input['roles']) && is_array($input['roles'])) {
$rolesRaw = $input['roles'];
} elseif (isset($input['id_rol']) && $input['id_rol'] !== '') {
$rolesRaw = [$input['id_rol']];
}
$roles = array_values(array_unique(array_filter(array_map('intval', $rolesRaw), fn($r) => $r > 0)));

if ($idUsuario <= 0 || $username === '' || $email === '' || empty($roles)) {
echo json_encode(['status' => 'error', 'message' => 'Todos los campos son obligatorios.']);
exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
echo json_encode(['status' => 'error', 'message' => 'Ingresa un correo electrónico válido.']);
exit;
}

try {
$stmtExists = $pdo->prepare("SELECT id_usuario FROM usuarios WHERE id_usuario = ?");
$stmtExists->execute([$idUsuario]);
if (!$stmtExists->fetch()) {
echo json_encode(['status' => 'error', 'message' => 'Este usuario ya no existe. Actualiza la lista e intenta de nuevo.']);
exit;
}

$placeholders = implode(',', array_fill(0, count($roles), '?'));
$stmtRol = $pdo->prepare("SELECT id_rol FROM rol WHERE id_rol IN ($placeholders)");
$stmtRol->execute($roles);
$rolesValidos = array_map('intval', $stmtRol->fetchAll(PDO::FETCH_COLUMN, 0));
if (count($rolesValidos) !== count($roles)) {
echo json_encode(['status' => 'error', 'message' => 'Uno o más roles seleccionados no existen.']);
exit;
}

$stmtDup = $pdo->prepare("SELECT id_usuario FROM usuarios WHERE (username = ? OR email = ?) AND id_usuario <> ?");
$stmtDup->execute([$username, $email, $idUsuario]);
if ($stmtDup->fetch()) {
echo json_encode(['status' => 'error', 'message' => 'Ya existe otro usuario con ese nombre de usuario o correo.']);
exit;
}

$rolesActuales = loadUserRoles($pdo, $idUsuario);

// Salvaguarda: si el usuario era Administrador y se le quita ese rol,
// debe quedar al menos otro Administrador.
$eraAdmin = in_array(1, $rolesActuales, true);
$seraAdmin = in_array(1, $roles, true);
if ($eraAdmin && !$seraAdmin) {
$stmtOtros = $pdo->prepare("
SELECT COUNT(DISTINCT ur.id_usuario)
FROM usuario_rol ur
INNER JOIN usuarios u ON u.id_usuario = ur.id_usuario
WHERE ur.id_rol = 1 AND ur.id_usuario <> ? AND u.estado = 'Activo'
");
$stmtOtros->execute([$idUsuario]);
if ((int) $stmtOtros->fetchColumn() === 0) {
echo json_encode(['status' => 'error', 'message' => 'No puedes quitarle el rol de Administrador: es el único administrador activo del sistema.']);
exit;
}
}

$pdo->beginTransaction();
try {
$stmtUpdate = $pdo->prepare("UPDATE usuarios SET username = ?, email = ? WHERE id_usuario = ?");
$stmtUpdate->execute([$username, $email, $idUsuario]);

// Reemplazo total de roles: DELETE + INSERT
$stmtDel = $pdo->prepare("DELETE FROM usuario_rol WHERE id_usuario = ?");
$stmtDel->execute([$idUsuario]);

$stmtIns = $pdo->prepare("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)");
foreach ($roles as $idRol) {
$stmtIns->execute([$idUsuario, $idRol]);
}

$pdo->commit();
echo json_encode(['status' => 'success', 'message' => 'Usuario actualizado correctamente.']);
} catch (Exception $e) {
$pdo->rollBack();
throw $e;
}
} catch (PDOException $e) {
$sqlCode = (int) ($e->errorInfo[1] ?? 0);
if ($sqlCode === 1062) {
echo json_encode(['status' => 'error', 'message' => 'Ya existe otro usuario con ese nombre de usuario o correo.']);
} else {
echo json_encode(['status' => 'error', 'message' => 'Error actualizando el usuario: ' . $e->getMessage()]);
}
} catch (Exception $e) {
echo json_encode(['status' => 'error', 'message' => 'Error actualizando el usuario: ' . $e->getMessage()]);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'usuarios', 'editar'). El acceso lo decide
// la matriz de permisos (rol_modulo_permiso) en lugar del id_rol.
// La salvaguarda del último Administrador se conserva intacta
// porque es una regla de negocio, no un permiso de página