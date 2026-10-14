<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'clientes');
requireOperation($pdo, 'clientes', 'editar');

/**
 * CORRECCIÓN FASE 2.5: este archivo tocaba `servicios` además de `clientes`,
 * asumiendo 1 cliente = 1 servicio (buscaba el servicio MÁS RECIENTE del
 * cliente y lo sobreescribía con lo que viniera en el formulario de
 * edición de cliente). Eso hacía imposible tener más de un servicio por
 * cliente y además corrompía silenciosamente el servicio "equivocado" si
 * el cliente tenía varios.
 *
 * Su responsabilidad se reduce ahora exclusivamente a la entidad
 * `clientes` (persona). La gestión de `servicios` (N por cliente) vive
 * en api_servicios.php.
 */

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
    $data = $_POST;
}

if (($data['accion'] ?? '') === 'provisionar_credencial') {
    $idCliente = filter_var($data['id_cliente'] ?? null, FILTER_VALIDATE_INT);
    if (!$idCliente || $idCliente <= 0) {
        http_response_code(422);
        echo json_encode(['status' => 'error', 'message' => 'Cliente inválido.']);
        exit;
    }

    try {
        $pdo->beginTransaction();
        $stmtCliente = $pdo->prepare('SELECT id_cliente, nombres, apellidos, cedula, correo FROM clientes WHERE id_cliente = ? FOR UPDATE');
        $stmtCliente->execute([$idCliente]);
        $cliente = $stmtCliente->fetch(PDO::FETCH_ASSOC);
        if (!$cliente) {
            http_response_code(404);
            echo json_encode(['status' => 'error', 'message' => 'Cliente no encontrado.']);
            exit;
        }

        $email = trim((string) $cliente['correo']);
        if (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
            http_response_code(422);
            echo json_encode(['status' => 'error', 'message' => 'El cliente necesita un correo válido para recibir la invitación.']);
            exit;
        }

        $stmtCredencial = $pdo->prepare('SELECT id_credencial, must_change_password FROM clientes_credenciales WHERE id_cliente = ? FOR UPDATE');
        $stmtCredencial->execute([$idCliente]);
        $credencial = $stmtCredencial->fetch(PDO::FETCH_ASSOC);
        if ($credencial && (int) $credencial['must_change_password'] !== 1) {
            http_response_code(409);
            echo json_encode(['status' => 'error', 'message' => 'El cliente ya activó su cuenta. El restablecimiento de acceso no está disponible en este flujo.']);
            exit;
        }

        $passwordTemporal = bin2hex(random_bytes(18));
        $passwordHash = password_hash($passwordTemporal, PASSWORD_DEFAULT);
        if ($passwordHash === false) {
            throw new RuntimeException('No se pudo generar el hash de la credencial.');
        }

        if ($credencial) {
            $idCredencial = (int) $credencial['id_credencial'];
            $stmt = $pdo->prepare("UPDATE clientes_credenciales
                SET username = ?, password = ?, correo_recuperacion = ?, estado = 'suspendida',
                    intentos_fallidos = 0, bloqueado_hasta = NULL, must_change_password = 1
                WHERE id_credencial = ?");
            $stmt->execute([$cliente['cedula'], $passwordHash, $email, $idCredencial]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO clientes_credenciales
                (id_cliente, username, password, correo_recuperacion, estado, must_change_password)
                VALUES (?, ?, ?, ?, 'suspendida', 1)");
            $stmt->execute([$idCliente, $cliente['cedula'], $passwordHash, $email]);
            $idCredencial = (int) $pdo->lastInsertId();
        }

        $pdo->prepare("DELETE FROM sesiones WHERE id_credencial = ? AND tipo_usuario = 'cliente'")
            ->execute([$idCredencial]);
        $pdo->commit();

        $baseUrl = trim((string) (getenv('REDYTELCA_BASE_URL') ?: ''));
        if ($baseUrl === '') {
            $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
            $scheme = $https ? 'https' : 'http';
            $host = $_SERVER['SERVER_NAME'] ?? 'localhost';
            $port = (int) ($_SERVER['SERVER_PORT'] ?? ($https ? 443 : 80));
            if (($https && $port !== 443) || (!$https && $port !== 80)) {
                $host .= ':' . $port;
            }
            $basePath = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
            $basePath = ($basePath === '/' || $basePath === '.') ? '' : rtrim($basePath, '/');
            $baseUrl = $scheme . '://' . $host . $basePath;
        }
        if (filter_var($baseUrl, FILTER_VALIDATE_URL) === false || !in_array(parse_url($baseUrl, PHP_URL_SCHEME), ['http', 'https'], true)) {
            throw new RuntimeException('La URL pública del portal no es válida.');
        }

        require_once __DIR__ . '/includes/email.php';
        enviarInvitacionPortalCliente(
            $email,
            trim($cliente['nombres'] . ' ' . $cliente['apellidos']),
            $cliente['cedula'],
            $passwordTemporal,
            rtrim($baseUrl, '/') . '/cliente'
        );

        $pdo->prepare("UPDATE clientes_credenciales SET estado = 'activa' WHERE id_credencial = ?")
            ->execute([$idCredencial]);

        echo json_encode(['status' => 'success', 'message' => 'Invitación enviada al correo registrado. El cliente deberá cambiar la contraseña al ingresar.']);
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log('Error al aprovisionar credencial del portal: ' . get_class($e));
        http_response_code(503);
        echo json_encode(['status' => 'error', 'message' => 'No se pudo enviar la invitación. Verifica el correo y la configuración SMTP.']);
    }
    exit;
}

if (empty($data['id_cliente']) || empty($data['nombres']) || empty($data['apellidos']) || empty($data['cedula']) || empty($data['telefono']) || empty($data['correo'])) {
    echo json_encode(['status' => 'error', 'message' => 'Faltan datos obligatorios']);
    exit;
}

$idCliente = (int) $data['id_cliente'];
$cedula = trim($data['cedula']);

$stmtExists = $pdo->prepare("SELECT id_cliente FROM clientes WHERE id_cliente = ?");
$stmtExists->execute([$idCliente]);
if (!$stmtExists->fetch()) {
    echo json_encode(['status' => 'error', 'message' => 'Este cliente ya no existe en la base de datos (pudo haber sido eliminado). Actualiza la lista de clientes e intenta de nuevo.']);
    exit;
}

$stmtDup = $pdo->prepare("SELECT id_cliente FROM clientes WHERE cedula = ? AND id_cliente <> ?");
$stmtDup->execute([$cedula, $idCliente]);
if ($stmtDup->fetch()) {
    echo json_encode(['status' => 'error', 'message' => 'Ya existe otro cliente registrado con esa cédula.']);
    exit;
}

try {
    $stmtCliente = $pdo->prepare(
        "UPDATE clientes SET nombres = ?, apellidos = ?, cedula = ?, num_telefono = ?, correo = ? WHERE id_cliente = ?"
    );
    $stmtCliente->execute([
        $data['nombres'],
        $data['apellidos'],
        $cedula,
        $data['telefono'],
        $data['correo'],
        $idCliente
    ]);

    echo json_encode(['status' => 'success', 'message' => 'Cliente actualizado correctamente']);
} catch (PDOException $e) {
    $sqlCode = (int) ($e->errorInfo[1] ?? 0);
    if ($sqlCode === 1062) {
        echo json_encode(['status' => 'error', 'message' => 'Ya existe otro cliente con esa cédula.']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error al actualizar cliente: ' . $e->getMessage()]);
    }
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Error al actualizar cliente: ' . $e->getMessage()]);
}