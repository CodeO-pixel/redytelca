<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
require 'conexion.php';

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
$input = $_POST;
}

$username = isset($input['username']) ? trim($input['username']) : '';
$password = isset($input['password']) ? trim($input['password']) : '';

if (empty($username) || empty($password)) {
http_response_code(400);
echo json_encode(['status' => 'error', 'message' => 'Credenciales incompletas.']);
exit;
}

try {
// Buscar usuario y su estado
$stmtUser = $pdo->prepare("
SELECT id_usuario, username, password, must_change_password, intentos_fallidos, bloqueado_hasta, estado,
(bloqueado_hasta IS NOT NULL AND bloqueado_hasta > NOW()) AS esta_bloqueado
FROM usuarios WHERE username = ?
");
$stmtUser->execute([$username]);
$userRow = $stmtUser->fetch(PDO::FETCH_ASSOC);

if (!$userRow) {
http_response_code(401);
echo json_encode(['status' => 'error', 'message' => 'Usuario o contraseña incorrectos.']);
exit;
}

if (!empty($userRow['esta_bloqueado'])) {
http_response_code(403);
echo json_encode(['status' => 'error', 'message' => 'Cuenta bloqueada por múltiples intentos fallidos. Intente en 15 minutos.']);
exit;
}

if ($userRow['estado'] !== 'Activo') {
http_response_code(403);
echo json_encode(['status' => 'error', 'message' => 'Usuario inactivo o bloqueado.']);
exit;
}

$idUsuario = (int) $userRow['id_usuario'];
$credencialesValidas = verificarYMigrarPassword($pdo, $password, $userRow['password'], $idUsuario);

if (!$credencialesValidas) {
// Manejo de intentos fallidos
$intentos = (int) $userRow['intentos_fallidos'] + 1;
if ($intentos >= 5) {
$stmtLock = $pdo->prepare("UPDATE usuarios SET intentos_fallidos = ?, bloqueado_hasta = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE id_usuario = ?");
$stmtLock->execute([$intentos, $idUsuario]);
} else {
$stmtFail = $pdo->prepare("UPDATE usuarios SET intentos_fallidos = ? WHERE id_usuario = ?");
$stmtFail->execute([$intentos, $idUsuario]);
}

http_response_code(401);
echo json_encode(['status' => 'error', 'message' => 'Usuario o contraseña incorrectos.']);
exit;
}

// Resetear intentos al acertar
$stmtReset = $pdo->prepare("UPDATE usuarios SET intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id_usuario = ?");
$stmtReset->execute([$idUsuario]);

// Obtener roles
$stmtRoles = $pdo->prepare("SELECT id_rol FROM usuario_rol WHERE id_usuario = ? ORDER BY id_rol");
$stmtRoles->execute([$idUsuario]);
$roles = array_map('intval', $stmtRoles->fetchAll(PDO::FETCH_COLUMN, 0));

$modulosPermitidos = [];
$rolNombre = 'Sin rol';

if (!empty($roles)) {
// Obtener módulos permitidos
$placeholders = implode(',', array_fill(0, count($roles), '?'));
$stmtModulos = $pdo->prepare("
SELECT m.id_modulo AS id_modulo,
m.nombre_modulo AS modulo,
p.nombre_pagina AS vista,
p.url_pagina AS url,
(SELECT GROUP_CONCAT(DISTINCT pe.nombre ORDER BY pe.id_permiso)
 FROM rol_modulo_permiso rmp2
 INNER JOIN permisos pe ON pe.id_permiso = rmp2.id_permiso
 WHERE rmp2.id_rol_modulo = rmpag.id_rol_modulo
   AND rmp2.id_pagina = rmpag.id_pagina) AS permisos
FROM rol_modulo_pagina rmpag
INNER JOIN rol_modulo rm ON rm.id_rol_modulo = rmpag.id_rol_modulo
INNER JOIN modulos m ON m.id_modulo = rmpag.id_modulo
INNER JOIN paginas p ON p.id_pagina = rmpag.id_pagina
WHERE rm.id_rol IN ($placeholders)
GROUP BY m.id_modulo, p.id_pagina
ORDER BY m.id_modulo, p.id_pagina
");
$stmtModulos->execute($roles);
$modulosPermitidos = $stmtModulos->fetchAll(PDO::FETCH_ASSOC);

// GROUP_CONCAT devuelve string "leer,crear,editar". Convertirlo a array.
foreach ($modulosPermitidos as &$modulo) {
$modulo['permisos'] = !empty($modulo['permisos'])
? explode(',', $modulo['permisos'])
: [];
}
unset($modulo);

// GRUPO E (B.3): Config Admin-only.
// Mismo filtro que auth_state.php. Si el usuario NO tiene el rol 1
// (Administrador), se eliminan los módulos del bloque Configuración
// (id_modulo = 4). Fundamento: NIST SP 800-53 AC-5 y AC-6.
if (!in_array(1, $roles, true)) {
$modulosPermitidos = array_values(array_filter($modulosPermitidos, function ($m) {
return (int) $m['id_modulo'] !== 4;
}));
}

// Nombre del rol principal
$stmtNombreRol = $pdo->prepare("SELECT nombre_rol FROM rol WHERE id_rol = ?");
$stmtNombreRol->execute([$roles[0]]);
$rolNombre = $stmtNombreRol->fetchColumn() ?: 'Sin rol';
}

// Limpiar sesiones muy antiguas
$stmtDelSesiones = $pdo->prepare("DELETE FROM sesiones WHERE id_usuario = ? AND expira_en < DATE_SUB(NOW(), INTERVAL 60 DAY)");
$stmtDelSesiones->execute([$idUsuario]);

// Crear nueva sesión
$token = bin2hex(random_bytes(32));
$expiraEn = gmdate('Y-m-d H:i:s', strtotime('+30 days'));
$ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? null;

$stmtSesion = $pdo->prepare("INSERT INTO sesiones (token, tipo_usuario, id_usuario, expira_en, ip_address, user_agent) VALUES (?, 'staff', ?, ?, ?, ?)");
$stmtSesion->execute([$token, $idUsuario, $expiraEn, $ipAddress, $userAgent]);

http_response_code(200);
echo json_encode([
'status' => 'success',
'usuario' => $userRow['username'],
'roles' => $roles,
'rol_nombre' => $rolNombre,
'token' => $token,
'modulos_permitidos' => $modulosPermitidos,
'must_change_password' => isset($userRow['must_change_password']) && (int)$userRow['must_change_password'] === 1
]);
} catch (Exception $e) {
http_response_code(500);
echo json_encode(['status' => 'error', 'message' => 'Error interno procesando el inicio de sesión.']);
}