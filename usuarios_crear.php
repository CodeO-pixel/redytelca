<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'usuarios');
requireOperation($pdo, 'usuarios', 'crear');

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
$data = $_POST;
}

$username = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');

// Aceptamos "id_rol" escalar (retrocompat) o "roles" array (nuevo).
$rolesRaw = [];
if (isset($data['roles']) && is_array($data['roles'])) {
$rolesRaw = $data['roles'];
} elseif (isset($data['id_rol']) && $data['id_rol'] !== '') {
$rolesRaw = [$data['id_rol']];
}
$roles = array_values(array_unique(array_filter(array_map('intval', $rolesRaw), fn($r) => $r > 0)));

if (!$username || !$email || empty($roles)) {
echo json_encode(['status' => 'error', 'message' => 'Usuario, correo y al menos un rol son obligatorios.']);
exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
echo json_encode(['status' => 'error', 'message' => 'Ingresa un correo electrónico válido.']);
exit;
}

$stmt = $pdo->prepare('SELECT id_usuario FROM usuarios WHERE username = ? OR email = ?');
$stmt->execute([$username, $email]);
if ($stmt->fetch()) {
echo json_encode(['status' => 'error', 'message' => 'Ese usuario o correo ya existe.']);
exit;
}

// Verificar que todos los roles existan
$placeholders = implode(',', array_fill(0, count($roles), '?'));
$stmtRol = $pdo->prepare("SELECT id_rol FROM rol WHERE id_rol IN ($placeholders)");
$stmtRol->execute($roles);
$rolesValidos = array_map('intval', $stmtRol->fetchAll(PDO::FETCH_COLUMN, 0));

if (count($rolesValidos) !== count($roles)) {
echo json_encode(['status' => 'error', 'message' => 'Uno o más roles seleccionados no existen.']);
exit;
}

$pdo->beginTransaction();
try {
$passwordTemporal = bin2hex(random_bytes(18));
$passwordHash = hashearPasswordNueva($passwordTemporal);
$stmt = $pdo->prepare('INSERT INTO usuarios (username, password, email, must_change_password, email_verified) VALUES (?, ?, ?, 1, 0)');
$stmt->execute([$username, $passwordHash, $email]);
$idUsuario = (int) $pdo->lastInsertId();

$stmtAsig = $pdo->prepare('INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)');
foreach ($roles as $idRol) {
$stmtAsig->execute([$idUsuario, $idRol]);
}

$baseUrl = trim((string) (getenv('REDYTELCA_BASE_URL') ?: ''));
if ($baseUrl === '') {
	$https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
	$scheme = $https ? 'https' : 'http';
	$host = $_SERVER['SERVER_NAME'] ?? 'localhost';
	$port = (int) ($_SERVER['SERVER_PORT'] ?? ($https ? 443 : 80));
	if (($https && $port !== 443) || (!$https && $port !== 80)) {
		$host .= ':' . $port;
	}
	$baseUrl = $scheme . '://' . $host . str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
}
$baseUrl = rtrim($baseUrl, '/');
$urlParts = parse_url($baseUrl);
$host = strtolower((string) ($urlParts['host'] ?? ''));
$isLocalHost = in_array($host, ['localhost', '127.0.0.1', '::1'], true);
if (filter_var($baseUrl, FILTER_VALIDATE_URL) === false || (($urlParts['scheme'] ?? '') !== 'https' && !$isLocalHost)) {
	throw new RuntimeException('La invitación de staff requiere una URL pública HTTPS válida.');
}

require_once __DIR__ . '/includes/email.php';
enviarInvitacionUsuarioStaff($email, $username, $passwordTemporal, $baseUrl . '/admin');

$pdo->commit();
echo json_encode([
'status' => 'success',
'message' => 'Usuario creado e invitación enviada. El usuario deberá cambiar la contraseña en su primer ingreso.'
]);
} catch (Throwable $e) {
$pdo->rollBack();
error_log('Error al crear usuario staff: ' . get_class($e));
http_response_code(503);
echo json_encode(['status' => 'error', 'message' => 'No se pudo crear el usuario o enviar la invitación. Verifica la URL HTTPS y la configuración SMTP.']);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'usuarios', 'crear'). El acceso lo decide
// la matriz de permisos (rol_modulo_permiso) en lugar del id_rol.
// Consistente con RBAC Core N:M. El Administrador conserva acceso
// porque su seed le da permisos 1-4 en todas las páginas.