<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
$staffSession = requireStaffAuth($pdo, null, true);

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
    $data = $_POST;
}

$username = trim($data['username'] ?? '');
$passwordActual = trim($data['password_actual'] ?? '');
$passwordNueva = trim($data['password_nueva'] ?? '');

$userId = isset($data['user_id']) ? intval($data['user_id']) : 0;

if ($staffSession['must_change_password'] && $userId > 0) {
    http_response_code(403);
    echo json_encode(['status' => 'error', 'message' => 'Debes cambiar tu propia contraseña antes de restablecer la de otro usuario.']);
    exit;
}

if (!$passwordNueva || (!$username && $userId <= 0)) {
    echo json_encode(['status' => 'error', 'message' => 'Todos los campos son obligatorios']);
    exit;
}

$longitudNueva = mb_strlen($passwordNueva, 'UTF-8');
if ($longitudNueva < 15 || $longitudNueva > 128) {
    http_response_code(422);
    echo json_encode(['status' => 'error', 'message' => 'La contraseña debe tener entre 15 y 128 caracteres.']);
    exit;
}

if ($userId > 0) {
    // Reset por Administrador: verificar que el staff que ejecuta tenga el rol 1
    if (!in_array(1, $staffSession['roles'], true)) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Solo un Administrador puede restablecer la contraseña de otro usuario.']);
        exit;
    }

    $stmt = $pdo->prepare('SELECT username FROM usuarios WHERE id_usuario = ?');
    $stmt->execute([$userId]);
    $userRow = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$userRow) {
        echo json_encode(['status' => 'error', 'message' => 'Usuario no encontrado']);
        exit;
    }

    $username = $userRow['username'];
    $mustChangeReset = true;
} else {
    if (!$passwordActual) {
        echo json_encode(['status' => 'error', 'message' => 'La contraseña actual es obligatoria']);
        exit;
    }

    if ($username !== $staffSession['username']) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'No puedes cambiar la contraseña de otro usuario por esta vía.']);
        exit;
    }

    $stmt = $pdo->prepare('SELECT id_usuario, password FROM usuarios WHERE username = ?');
    $stmt->execute([$username]);
    $userRow = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$userRow || !verificarYMigrarPassword($pdo, $passwordActual, $userRow['password'], (int) $userRow['id_usuario'])) {
        echo json_encode(['status' => 'error', 'message' => 'La contraseña actual es incorrecta']);
        exit;
    }
}

$passwordNuevaHash = hashearPasswordNueva($passwordNueva);

try {
    if (isset($mustChangeReset) && $mustChangeReset) {
        $update = $pdo->prepare('UPDATE usuarios SET password = ?, must_change_password = 1 WHERE username = ?');
        $ok = $update->execute([$passwordNuevaHash, $username]);
    } else {
        $update = $pdo->prepare('UPDATE usuarios SET password = ?, must_change_password = 0 WHERE username = ?');
        $ok = $update->execute([$passwordNuevaHash, $username]);
    }

    echo json_encode([
        'status' => $ok ? 'success' : 'error',
        'message' => $ok ? 'Contraseña actualizada correctamente' : 'No se pudo actualizar la contraseña'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Error al actualizar la contraseña.']);
}