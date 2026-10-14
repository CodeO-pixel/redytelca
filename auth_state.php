<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
require 'conexion.php';

// Leer token SOLO del header X-Session-Token
$token = '';
if (isset($_SERVER['HTTP_X_SESSION_TOKEN']) && trim($_SERVER['HTTP_X_SESSION_TOKEN']) !== '') {
$token = trim($_SERVER['HTTP_X_SESSION_TOKEN']);
}

if ($token === '') {
echo json_encode(['status' => 'success', 'authenticated' => false]);
exit;
}

try {
// Buscar sesión válida de staff
$stmt = $pdo->prepare("
SELECT s.id_sesion, s.id_usuario, u.username, u.must_change_password
FROM sesiones s
INNER JOIN usuarios u ON u.id_usuario = s.id_usuario
WHERE s.token = ? AND s.expira_en > NOW() AND s.tipo_usuario = 'staff'
");
$stmt->execute([$token]);
$sesion = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$sesion) {
echo json_encode(['status' => 'success', 'authenticated' => false]);
exit;
}

// Renovar expiración de la sesión (deslizante 30 días)
$nuevaExpiracion = gmdate('Y-m-d H:i:s', strtotime('+30 days'));
$stmtRenovar = $pdo->prepare('UPDATE sesiones SET expira_en = ? WHERE id_sesion = ?');
$stmtRenovar->execute([$nuevaExpiracion, $sesion['id_sesion']]);

$idUsuario = (int) $sesion['id_usuario'];

// Obtener roles del usuario
$stmtRoles = $pdo->prepare("SELECT id_rol FROM usuario_rol WHERE id_usuario = ? ORDER BY id_rol");
$stmtRoles->execute([$idUsuario]);
$roles = array_map('intval', $stmtRoles->fetchAll(PDO::FETCH_COLUMN, 0));

$modulosPermitidos = [];
$rolNombre = 'Sin rol';

if (!empty($roles)) {
// Obtener módulos y páginas permitidas
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
// Si el usuario NO tiene el rol 1 (Administrador), filtrar los módulos
// del bloque "Configuración" (id_modulo = 4). Fundamento: NIST SP 800-53
// AC-5 (SoD) y AC-6 (Mínimo Privilegio). El backend se convierte en la
// fuente de verdad que impide que un rol no-Admin reciba módulos de
// Configuración aunque la matriz de permisos los tenga asignados.
if (!in_array(1, $roles, true)) {
$modulosPermitidos = array_values(array_filter($modulosPermitidos, function ($m) {
return (int) $m['id_modulo'] !== 4;
}));
}

// Obtener el nombre del rol principal
$stmtNombreRol = $pdo->prepare("SELECT nombre_rol FROM rol WHERE id_rol = ?");
$stmtNombreRol->execute([$roles[0]]);
$rolNombre = $stmtNombreRol->fetchColumn() ?: 'Sin rol';
}

echo json_encode([
'status' => 'success',
'authenticated' => true,
'user' => $sesion['username'],
'roles' => $roles,
'roleName' => $rolNombre,
'token' => $token,
'modules' => $modulosPermitidos,
'must_change_password' => isset($sesion['must_change_password']) && (int)$sesion['must_change_password'] === 1
]);
} catch (Exception $e) {
// Log interno omitido por simplicidad, pero no se expone al cliente
http_response_code(500);
echo json_encode(['status' => 'error', 'message' => 'Error validando la sesión.']);
}