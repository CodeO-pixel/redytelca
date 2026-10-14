<?php
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
require 'conexion.php';

/**
 * Endpoint público para branding pre-login (nombre, logo, color).
 * 
 * ¿Por qué es público y está separado de api_empresa.php?
 * Este endpoint permite pintar la pantalla de login antes de que el usuario
 * se autentique, sin exponer configuración sensible del negocio (impuestos,
 * días de gracia, mora, facturación) que sí maneja api_empresa.php.
 * 
 * Respaldo de industria:
 * - Okta: GET /api/public/clientid2brand/{clientId} devuelve branding antes de renderizar el sign-in widget.
 * - Microsoft Entra External ID: neutral branding visible por defecto, configuración completa vía Graph API protegida.
 * - Auth0: Authentication API pública vs Management API protegida.
 * 
 * Referencia: spec 024 (proteger-api-empresa, hallazgo B09).
 */

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("SELECT nombre_empresa, logo_path, color_primario FROM configuracion_empresa WHERE id_config = 1");
        $config = $stmt->fetch(PDO::FETCH_ASSOC);

        echo json_encode([
            'status' => 'success',
            'config' => $config ?: null
        ]);
    } catch (Exception $e) {
        // CWE-209: No exponer $e->getMessage() al cliente en endpoints públicos
        echo json_encode([
            'status' => 'error',
            'message' => 'Error obteniendo la configuración pública.'
        ]);
    }
    exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);