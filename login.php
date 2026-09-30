<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

function loadAllowedViews(PDO $pdo, int $roleId): array {
    $stmt = $pdo->prepare("SELECT m.nombre_modulo AS modulo, p.nombre_pagina AS vista, p.url_pagina AS url
        FROM rol_modulo_pagina rmp
        INNER JOIN modulos m ON rmp.id_modulo = m.id_modulo
        INNER JOIN paginas p ON rmp.id_pagina = p.id_pagina
        WHERE rmp.id_rol = ?
        ORDER BY m.id_modulo, p.id_pagina");
    $stmt->execute([$roleId]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_map(fn($row) => [
        'modulo' => $row['modulo'],
        'vista' => $row['vista'],
        'url' => $row['url']
    ], $rows);
}

$input = json_decode(file_get_contents('php://input'), true);
$username = isset($input['username']) ? trim($input['username']) : '';
$password = isset($input['password']) ? trim($input['password']) : '';

if (empty($username) || empty($password)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Credenciales incompletas.']);
    exit;
}

try {
    // Auto-reparación de esquema eliminada (Prompt 9-bis): sesiones ya es
    // nativa en bd_redytelca.sql desde Fase 0, con el esquema completo de
    // 3 capas de identidad (tipo_usuario, id_credencial) que esta función
    // desconocía — de haberse ejecutado alguna vez contra una tabla ausente,
    // habría creado un esquema incompatible con el modelo vigente.

    $stmtAnyUser = $pdo->query("SELECT COUNT(*) FROM usuarios");
    $totalUsers = (int) $stmtAnyUser->fetchColumn();
    if ($totalUsers === 0) {
        // FASE 1 (pendiente resuelto): admin de emergencia también hasheado.
        $pdo->prepare("INSERT IGNORE INTO usuarios (username, password, id_rol) VALUES (?, ?, ?)")
            ->execute(['admin', hashearPasswordNueva('123456'), 1]);
    }

    $stmtUser = $pdo->prepare("SELECT id_usuario, username, password, id_rol, must_change_password, email_verified FROM usuarios WHERE username = ?");
    $stmtUser->execute([$username]);
    $userRow = $stmtUser->fetch();

    if (!$userRow) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Usuario o contraseña incorrectos.']);
        exit;
    }

    $credencialesValidas = verificarYMigrarPassword($pdo, $password, $userRow['password'], (int) $userRow['id_usuario']);

    if (!$credencialesValidas) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Usuario o contraseña incorrectos.']);
        exit;
    }

    if (empty($userRow['email_verified'])) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Debes verificar tu correo antes de iniciar sesión. Revisa tu bandeja de entrada.']);
        exit;
    }

    $stmtRole = $pdo->prepare("SELECT nombre_rol FROM rol WHERE id_rol = ?");
    $stmtRole->execute([$userRow['id_rol']]);
    $roleRow = $stmtRole->fetch();

    $modules = loadAllowedViews($pdo, (int) $userRow['id_rol']);

    // Política de sesión única suavizada: eliminamos únicamente sesiones
    // muy antiguas del mismo usuario (p. ej. expiradas hace más de 60 días)
    // para permitir acumular historial reciente en la tabla de auditoría.
    $stmtDelSesiones = $pdo->prepare(
        "DELETE FROM sesiones WHERE id_usuario = ? AND expira_en < DATE_SUB(NOW(), INTERVAL 60 DAY)"
    );
    $stmtDelSesiones->execute([$userRow['id_usuario']]);

    $token = bin2hex(random_bytes(32));
    $expiraEn = date('Y-m-d H:i:s', strtotime('+30 days'));
    $stmtSesion = $pdo->prepare("INSERT INTO sesiones (token, id_usuario, expira_en) VALUES (?, ?, ?)");
    $stmtSesion->execute([$token, $userRow['id_usuario'], $expiraEn]);

    // Se mantiene $_SESSION por compatibilidad con código legado que aún
    // pudiera leerlo, pero la fuente de verdad para persistencia entre
    // recargas ahora es la tabla `sesiones`, no el ciclo de vida de PHP.
    $_SESSION['auth_token'] = $token;
    $_SESSION['id_usuario'] = (int) $userRow['id_usuario'];
    $_SESSION['id_rol'] = (int) $userRow['id_rol'];
    $_SESSION['usuario'] = $userRow['username'];
    $_SESSION['rol_nombre'] = $roleRow['nombre_rol'] ?? 'Rol';
    $_SESSION['modulos_permitidos'] = $modules;

    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'usuario' => $userRow['username'],
        'id_rol' => (int) $userRow['id_rol'],
        'rol_nombre' => $_SESSION['rol_nombre'],
        'token' => $token,
        'modulos_permitidos' => $modules,
        'must_change_password' => isset($userRow['must_change_password']) && $userRow['must_change_password'] == 1
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Error interno del servidor al procesar el control de accesos.'
    ]);
}