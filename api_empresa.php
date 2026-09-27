<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';

$staffSession = requireStaffAuth($pdo, 1);
$method = $_SERVER['REQUEST_METHOD'];
$pdo->exec("UPDATE configuracion_empresa SET color_primario = '#2563eb' WHERE color_primario = '#0f172a'");

if ($method === 'GET') {
    $stmt = $pdo->query("SELECT id_config, nombre_empresa, logo_path, color_primario FROM configuracion_empresa WHERE id_config = 1");
    $config = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$config) {
        $pdo->exec("INSERT INTO configuracion_empresa (id_config, nombre_empresa, logo_path, color_primario) VALUES (1, 'REDYTELCA', 'Logos/logo_transparent.png', '#2563eb')");
        $config = [
            'id_config' => 1,
            'nombre_empresa' => 'REDYTELCA',
            'logo_path' => 'Logos/logo_transparent.png',
            'color_primario' => '#2563eb'
        ];
    }

    echo json_encode(['status' => 'success', 'config' => $config]);
    exit;
}

if ($method === 'POST') {
    $nombre = isset($_POST['nombre_empresa']) ? trim($_POST['nombre_empresa']) : '';
    $color = isset($_POST['color_primario']) ? trim($_POST['color_primario']) : '#2563eb';

    $logoPath = null;
    if (isset($_FILES['logo']) && $_FILES['logo']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = 'uploads/empresa/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }

        $ext = pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
        $filename = 'logo.' . ($ext ?: 'png');
        $targetPath = $uploadDir . $filename;

        if (move_uploaded_file($_FILES['logo']['tmp_name'], $targetPath)) {
            $logoPath = $targetPath;
        }
    }

    $fields = [];
    $params = [];

    if ($nombre !== '') {
        $fields[] = 'nombre_empresa = ?';
        $params[] = $nombre;
    }

    if ($color !== '') {
        $fields[] = 'color_primario = ?';
        $params[] = $color;
    }

    if ($logoPath !== null) {
        $fields[] = 'logo_path = ?';
        $params[] = $logoPath;
    }

    if (empty($fields)) {
        echo json_encode(['status' => 'error', 'message' => 'No se enviaron datos para actualizar']);
        exit;
    }

    $sql = 'UPDATE configuracion_empresa SET ' . implode(', ', $fields) . ' WHERE id_config = 1';
    $stmt = $pdo->prepare($sql);
    $ok = $stmt->execute($params);

    echo json_encode([
        'status' => $ok ? 'success' : 'error',
        'message' => $ok ? 'Configuración actualizada' : 'No se pudo actualizar'
    ]);
    exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);
