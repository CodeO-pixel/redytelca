<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
require_once __DIR__ . '/includes/email.php';
requireStaffAuth($pdo, 1);

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
    $data = $_POST;
}

$username = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');
$idRol = isset($data['id_rol']) ? intval($data['id_rol']) : 0;
$tempPassword = 'Rt#' . substr(bin2hex(random_bytes(4)), 0, 6);

if (!$username || !$email || $idRol <= 0) {
    echo json_encode(['status' => 'error', 'message' => 'Todos los campos son obligatorios']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['status' => 'error', 'message' => 'Ingresa un correo electrónico válido']);
    exit;
}

$stmt = $pdo->prepare('SELECT id_usuario FROM usuarios WHERE username = ? OR email = ?');
$stmt->execute([$username, $email]);
if ($stmt->fetch()) {
    echo json_encode(['status' => 'error', 'message' => 'Ese nombre de usuario o correo electrónico ya está registrado.']);
    exit;
}

try {
    $baseUrl = rtrim((string) getenv('REDYTELCA_BASE_URL'), '/');
    if ($baseUrl === '') {
        throw new RuntimeException('Falta configurar REDYTELCA_BASE_URL.');
    }

    $token = bin2hex(random_bytes(32));
    $pdo->beginTransaction();

    $stmt = $pdo->prepare('INSERT INTO usuarios (username, password, id_rol, email, must_change_password, email_verified) VALUES (?, ?, ?, ?, 1, 0)');
    $stmt->execute([$username, hashearPasswordNueva($tempPassword), $idRol, $email]);
    $idUsuario = (int) $pdo->lastInsertId();

    $stmt = $pdo->prepare('INSERT INTO email_verification_tokens (id_usuario, token_hash, expira_en) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR))');
    $stmt->execute([$idUsuario, hash('sha256', $token)]);

    $verificationUrl = $baseUrl . '/verificar_email_enlace.php?t=' . rawurlencode($token);
    enviarCorreoVerificacion($email, $username, $verificationUrl);
    $pdo->commit();

    echo json_encode([
        'status' => 'success',
        'message' => 'Usuario creado. Se envió un enlace de verificación al correo; vence en 24 horas. Contraseña temporal: ' . $tempPassword . '. Deberá cambiarla en su primer inicio de sesión.'
    ]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('Error creando usuario o enviando verificación: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'No se pudo crear el usuario o enviar el correo. Verifica la configuración SMTP y REDYTELCA_BASE_URL.'
    ]);
}