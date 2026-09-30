<?php
require 'conexion.php';

function mostrarResultado(string $titulo, string $mensaje, int $status): void {
    http_response_code($status);
    header('Content-Type: text/html; charset=utf-8');
    $safeTitle = htmlspecialchars($titulo, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $safeMessage = htmlspecialchars($mensaje, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    echo '<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>' . $safeTitle . '</title><body><main><h1>' . $safeTitle . '</h1><p>' . $safeMessage . '</p></main></body></html>';
    exit;
}

$token = trim((string) ($_GET['t'] ?? ''));
if (!preg_match('/^[a-f0-9]{64}$/', $token)) {
    mostrarResultado('Enlace inválido', 'El enlace de verificación no es válido.', 400);
}

try {
    $pdo->beginTransaction();
    $stmt = $pdo->prepare('SELECT id_usuario FROM email_verification_tokens WHERE token_hash = ? AND expira_en > NOW() FOR UPDATE');
    $stmt->execute([hash('sha256', $token)]);
    $idUsuario = $stmt->fetchColumn();

    if (!$idUsuario) {
        $pdo->rollBack();
        mostrarResultado('Enlace vencido', 'El enlace no existe o venció. Solicita un nuevo enlace al administrador.', 400);
    }

    $stmt = $pdo->prepare('UPDATE usuarios SET email_verified = 1 WHERE id_usuario = ?');
    $stmt->execute([(int) $idUsuario]);
    $stmt = $pdo->prepare('DELETE FROM email_verification_tokens WHERE id_usuario = ?');
    $stmt->execute([(int) $idUsuario]);
    $pdo->commit();

    mostrarResultado('Correo verificado', 'Tu correo quedó verificado. Ya puedes iniciar sesión en REDYTELCA.', 200);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('Error al verificar correo: ' . $e->getMessage());
    mostrarResultado('Error', 'No se pudo completar la verificación. Intenta nuevamente más tarde.', 500);
}