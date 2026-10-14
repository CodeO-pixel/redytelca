<?php
/**
 * REDYTELCA - branding.css.php
 *
 * ¿Por qué es un archivo PHP sirviendo CSS?
 * Este archivo se carga de forma síncrona y render-blocking en el <head>
 * antes de styles.css. Su propósito es inyectar las variables CSS dinámicas
 * de la empresa (--accent y --accent-rgb) directamente en el primer frame
 * de renderizado, eliminando el FOUC (Flash Of Unbranded Content) en la
 * pantalla de login.
 *
 * Referencias:
 * - Chroma Design System: inyección de tokens de diseño en runtime.
 * - ADR 009: Separación de configuración pública (branding) y protegida.
 */

header('Content-Type: text/css; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');

$color = '#104aa8';

try {
    require 'conexion.php';

    $stmt = $pdo->query("SELECT color_primario FROM configuracion_empresa WHERE id_config = 1");
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row && !empty($row['color_primario'])) {
        $dbColor = trim($row['color_primario']);
        if (preg_match('/^#[0-9a-fA-F]{6}$/', $dbColor)) {
            $color = $dbColor;
        }
    }
} catch (Exception $e) {
    // Silencioso: si falla la conexión o la query, usamos el fallback 
    // y emitimos el CSS igual para no romper la interfaz.
}

$hex = str_replace('#', '', $color);
$r = hexdec(substr($hex, 0, 2));
$g = hexdec(substr($hex, 2, 2));
$b = hexdec(substr($hex, 4, 2));

echo ":root { --accent: {$color}; --accent-rgb: {$r}, {$g}, {$b}; }\n";