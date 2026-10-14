<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'pagos');
requireOperation($pdo, 'pagos', 'leer');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("SELECT id_metodo, codigo, nombre, requiere_referencia, orden 
                             FROM metodos_pago 
                             WHERE activo = 1 
                             ORDER BY orden ASC, nombre ASC");
        $metodos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'status' => 'success',
            'metodos' => $metodos
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode([
            'status' => 'error',
            'message' => 'Error cargando métodos de pago. Contacta al administrador si persiste.'
        ]);
    }
    exit;
}

http_response_code(405);
echo json_encode([
    'status' => 'error',
    'message' => 'Método no soportado'
]);