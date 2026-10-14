<?php
/**
 * Cabeceras CORS centralizadas + conexión PDO + middlewares de autenticación
 * y autorización.
 */
$allowedOriginsEnv = getenv('REDYTELCA_ALLOWED_ORIGINS');
$allowedOrigins = $allowedOriginsEnv !== false && trim($allowedOriginsEnv) !== ''
    ? array_map('trim', explode(',', $allowedOriginsEnv))
    : ['http://localhost', 'http://localhost:80', 'http://127.0.0.1', 'http://127.0.0.1:80'];

if (php_sapi_name() !== 'cli') {
    $requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';

    if ($requestOrigin !== '' && in_array($requestOrigin, $allowedOrigins, true)) {
        header('Access-Control-Allow-Origin: ' . $requestOrigin);
    } elseif (empty($allowedOriginsEnv)) {
        header('Access-Control-Allow-Origin: ' . $allowedOrigins[0]);
    }

    header('Access-Control-Allow-Headers: Content-Type, X-Session-Token');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Vary: Origin');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');

    if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}

// Fijar el runtime de PHP a UTC para alinearlo con la conexión PDO
// (SET time_zone = '+00:00'). Sin esto, strtotime() y date() operan
// en date.timezone de php.ini, lo que produce desfases por DST en
// cálculos relativos (ej. '+30 days' atravesando un cambio de hora).
date_default_timezone_set('UTC');

$host = getenv('DB_HOST') ?: 'localhost';
$port = (int) (getenv('DB_PORT') ?: 3306);
$dbname = getenv('DB_NAME') ?: 'bd_redytelca';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASS') ?: '';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec("SET time_zone = '+00:00'");
} catch (PDOException $e) {
    if (php_sapi_name() !== 'cli') {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Error de conexión a la base de datos."]);
        exit;
    }
    throw $e;
}

function verificarYMigrarPassword(PDO $pdo, string $passwordIngresada, string $passwordAlmacenada, int $idUsuario): bool {
    $infoHash = password_get_info($passwordAlmacenada);

    if ($infoHash['algo'] !== null && $infoHash['algo'] !== 0) {
        return password_verify($passwordIngresada, $passwordAlmacenada);
    }

    if (hash_equals($passwordAlmacenada, $passwordIngresada)) {
        $nuevoHash = password_hash($passwordIngresada, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare('UPDATE usuarios SET password = ? WHERE id_usuario = ?');
        $stmt->execute([$nuevoHash, $idUsuario]);
        return true;
    }

    return false;
}

function hashearPasswordNueva(string $passwordPlana): string {
    return password_hash($passwordPlana, PASSWORD_DEFAULT);
}

/**
 * Establece el contexto de auditoría en la conexión PDO actual.
 * Las variables @app_* son por conexión. Este proyecto NO usa PDO::ATTR_PERSISTENT.
 * Si algún día se habilita persistencia, hay que resetear las variables al abrir la conexión.
 */
function setAuditContext(PDO $pdo, string $tipoActor, ?int $idUsuario, ?int $idCredencial): void {
    if ($tipoActor !== 'staff' && $tipoActor !== 'cliente') {
        throw new InvalidArgumentException("tipoActor debe ser 'staff' o 'cliente'");
    }
    
    $u = $idUsuario !== null ? intval($idUsuario) : 'NULL';
    $c = $idCredencial !== null ? intval($idCredencial) : 'NULL';
    $t = $pdo->quote($tipoActor);
    
    $pdo->exec("SET @app_usuario_id = $u, @app_credencial_id = $c, @app_tipo_actor = $t");
}

function loadUserRoles(PDO $pdo, int $idUsuario): array {
    if ($idUsuario <= 0) {
        return [];
    }
    $stmt = $pdo->prepare("SELECT id_rol FROM usuario_rol WHERE id_usuario = ? ORDER BY id_rol");
    $stmt->execute([$idUsuario]);
    return array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN, 0));
}

function loadUserRoleNames(PDO $pdo, int $idUsuario): array {
    if ($idUsuario <= 0) {
        return [];
    }
    $stmt = $pdo->prepare("SELECT r.nombre_rol FROM usuario_rol ur INNER JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ? ORDER BY r.id_rol");
    $stmt->execute([$idUsuario]);
    return $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
}

function requireStaffAuth(PDO $pdo, ?int $minRoleId = null, bool $allowMustChangePassword = false): array {
    $token = null;

    if (isset($_SERVER['HTTP_X_SESSION_TOKEN']) && trim((string) $_SERVER['HTTP_X_SESSION_TOKEN']) !== '') {
        $token = trim((string) $_SERVER['HTTP_X_SESSION_TOKEN']);
    }

    if ($token === null || $token === '') {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'No autenticado. Inicia sesión nuevamente.']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT s.id_sesion, s.id_usuario, u.username, u.must_change_password
        FROM sesiones s
        INNER JOIN usuarios u ON u.id_usuario = s.id_usuario
        WHERE s.token = ?
          AND (s.tipo_usuario = 'staff' OR s.tipo_usuario IS NULL)
          AND s.expira_en > NOW()");
    $stmt->execute([$token]);
    $sesion = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$sesion) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Sesión inválida o expirada.']);
        exit;
    }

    $mustChangePassword = (int) ($sesion['must_change_password'] ?? 0) === 1;
    if ($mustChangePassword && !$allowMustChangePassword) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Debes cambiar tu contraseña antes de continuar.']);
        exit;
    }

    $idUsuario = (int) $sesion['id_usuario'];
    $stmtRoles = $pdo->prepare("SELECT id_rol FROM usuario_rol WHERE id_usuario = ? ORDER BY id_rol");
    $stmtRoles->execute([$idUsuario]);
    $roles = array_map('intval', $stmtRoles->fetchAll(PDO::FETCH_COLUMN, 0));

    if (empty($roles)) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Tu cuenta no tiene roles asignados. Contacta a un Administrador.']);
        exit;
    }

    if ($minRoleId !== null) {
        $hasMinRole = false;
        foreach ($roles as $r) {
            if ($r <= $minRoleId) {
                $hasMinRole = true;
                break;
            }
        }
        if (!$hasMinRole) {
            http_response_code(403);
            echo json_encode(['status' => 'error', 'message' => 'No tienes permisos suficientes para esta acción.']);
            exit;
        }
    }

    setAuditContext($pdo, 'staff', $idUsuario, null);

    return [
        'id_usuario' => $idUsuario,
        'username' => $sesion['username'],
        'roles' => $roles,
        'es_admin' => in_array(1, $roles, true),
        'must_change_password' => $mustChangePassword,
    ];
}

function requirePageAccess(PDO $pdo, string $urlPagina): array {
    $staffSession = requireStaffAuth($pdo);

    // GUARD SoD Configuración (RBAC-02):
    // El módulo Configuración (id_modulo = 4) está reservado al rol
    // Administrador (id_rol = 1). El guard actúa ANTES de la consulta
    // de visibilidad, independientemente de lo que diga el seed o la
    // matriz de permisos. Fundamento: Google Cloud IAM Deny Policies +
    // NIST SP 800-53 AC-5 (Separación de Funciones).
    $stmtModuloSoD = $pdo->prepare("SELECT id_modulo FROM paginas WHERE url_pagina = ?");
    $stmtModuloSoD->execute([$urlPagina]);
    $idModuloPaginaSoD = $stmtModuloSoD->fetchColumn();

    if ((int) $idModuloPaginaSoD === 4 && !in_array(1, $staffSession['roles'], true)) {
        http_response_code(403);
        echo json_encode([
            'status' => 'error',
            'message' => 'Acceso denegado. La gestión de la configuración del sistema está reservada exclusivamente al rol Administrador por políticas de Separación de Funciones (SoD).'
        ]);
        exit;
    }

    // Consulta rol_modulo_pagina (nivel 1 de RBAC dos niveles, spec 099)
    $placeholders = implode(',', array_fill(0, count($staffSession['roles']), '?'));
    $sql = "SELECT 1 
            FROM rol_modulo_pagina rmpag
            INNER JOIN rol_modulo rm ON rm.id_rol_modulo = rmpag.id_rol_modulo
            INNER JOIN paginas p ON p.id_pagina = rmpag.id_pagina
            WHERE rm.id_rol IN ($placeholders) AND p.url_pagina = ?
            LIMIT 1";
    
    $params = array_merge($staffSession['roles'], [$urlPagina]);
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode([
            'status' => 'error',
            'message' => 'Tu rol no tiene habilitado este módulo. Pide a un Administrador que active esta vista desde Configuración > Permisos.'
        ]);
        exit;
    }

    return $staffSession;
}

function requireOperation(PDO $pdo, string $urlPagina, string $operacion): array {
    $staffSession = requireStaffAuth($pdo);

    $placeholders = implode(',', array_fill(0, count($staffSession['roles']), '?'));
    $sql = "SELECT 1 
            FROM rol_modulo_permiso rmp
            INNER JOIN rol_modulo rm ON rm.id_rol_modulo = rmp.id_rol_modulo
            INNER JOIN paginas p ON p.id_pagina = rmp.id_pagina
            INNER JOIN permisos pe ON pe.id_permiso = rmp.id_permiso
            WHERE rm.id_rol IN ($placeholders) AND p.url_pagina = ? AND pe.nombre = ?
            LIMIT 1";
    
    $params = array_merge($staffSession['roles'], [$urlPagina, $operacion]);
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);

    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode([
            'status' => 'error',
            'message' => 'Tu rol no tiene el permiso "' . $operacion . '" sobre esta página. Pide a un Administrador que lo active desde Configuración > Permisos.'
        ]);
        exit;
    }

    return $staffSession;
}

function requireClientAuth(PDO $pdo): array {
    $token = null;

    if (isset($_SERVER['HTTP_X_SESSION_TOKEN']) && trim((string) $_SERVER['HTTP_X_SESSION_TOKEN']) !== '') {
        $token = trim((string) $_SERVER['HTTP_X_SESSION_TOKEN']);
    }

    if ($token === null || $token === '') {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'No autenticado. Inicia sesión nuevamente.']);
        exit;
    }

    $stmt = $pdo->prepare("SELECT s.id_sesion, s.id_credencial, cc.id_cliente
        FROM sesiones s
        INNER JOIN clientes_credenciales cc ON cc.id_credencial = s.id_credencial
        WHERE s.token = ?
          AND s.tipo_usuario = 'cliente'
          AND s.expira_en > NOW()");
    $stmt->execute([$token]);
    $sesion = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$sesion) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Sesión inválida o expirada.']);
        exit;
    }

    $idCredencial = (int) $sesion['id_credencial'];
    setAuditContext($pdo, 'cliente', null, $idCredencial);

    return [
        'id_credencial' => $idCredencial,
        'id_cliente' => (int) $sesion['id_cliente'],
    ];
}

// ============================================================================
// CAMBIOS APLICADOS EN ESTA REVISIÓN
// ============================================================================
// Se agregaron las funciones loadUserRoles() y loadUserRoleNames() para
// resolver fatal errors en api_perfil.php, usuarios_editar.php y
// usuarios_eliminar.php al consultar los roles del usuario en el nuevo
// esquema RBAC N:M (usuario_rol).
// ============================================================================