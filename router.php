<?php
// Simple router: /cliente -> portal de pago, /admin -> aplicación admin (index.html)
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = trim($uri, '/');
$parts = explode('/', $uri === '' ? '/' : $uri);
$first = $parts[0] ?? '';

if ($first === 'cliente' || $first === 'portal' || $first === 'pagos' || $first === 'pago') {
    // Serve payment portal
    require __DIR__ . '/portal_cliente.php';
    exit;
}

if ($first === 'admin' || $first === '') {
    // Serve admin SPA (index.html) so it can handle client-side routes
    $index = __DIR__ . '/index.html';
    if (file_exists($index)) {
        header('Content-Type: text/html; charset=utf-8');
        readfile($index);
        exit;
    }
}

// Allowed static asset extensions
$allowedExts = ['css', 'js', 'png', 'jpg', 'jpeg', 'webp', 'svg', 'ico', 'woff', 'woff2', 'ttf', 'pdf'];
$ext = strtolower(pathinfo($uri, PATHINFO_EXTENSION));

$path = __DIR__ . '/' . $uri;
if (in_array($ext, $allowedExts, true) && file_exists($path) && is_file($path)) {
    $mimeTypes = [
        'css' => 'text/css',
        'js' => 'application/javascript',
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        'svg' => 'image/svg+xml',
        'ico' => 'image/x-icon',
        'pdf' => 'application/pdf'
    ];
    if (isset($mimeTypes[$ext])) {
        header('Content-Type: ' . $mimeTypes[$ext]);
    }
    readfile($path);
    exit;
}

http_response_code(404);
echo "404 Not Found";
