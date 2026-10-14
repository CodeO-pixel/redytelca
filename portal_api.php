<?php
/**
 * API del portal de clientes.
 *
 * Reemplaza al antiguo "/api_pagar.php" (que no existía) y a los datos
 * inventados de la maqueta anterior. Todo sale de la base de datos real.
 *
 *  POST  action=login     {cedula, password}          -> token de sesión
 *  GET   action=resumen                                -> cliente, servicios, facturas, pagos, tickets
 *  POST  action=pago      {id_factura, metodo, referencia, monto}
 *  POST  action=ticket    {asunto, descripcion, id_servicio?}
 *  POST  action=password  {actual, nueva}
 *  POST  action=logout
 *
 * Acceso: cédula y contraseña contra un hash provisionado previamente en
 * clientes_credenciales. El login no crea credenciales.
 */
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';

function out(array $data, int $code = 200): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!is_array($input)) {
    $input = $_POST;
}
$action = $_GET['action'] ?? ($input['action'] ?? '');

try {
    /* ---------------------------- LOGIN ---------------------------- */
    if ($action === 'login') {
        $cedulaInput = trim((string) ($input['cedula'] ?? ''));
        $password = (string) ($input['password'] ?? '');
        if ($cedulaInput === '' || $password === '') {
            out(['status' => 'error', 'message' => 'Ingresa tu cédula y contraseña para continuar.'], 422);
        }

        if (!preg_match('/^(?:[VEJPG]-)?[0-9]{6,9}$/i', $cedulaInput)) {
            out(['status' => 'error', 'message' => 'Cédula o contraseña incorrectas.'], 401);
        }

        $cleanInput = preg_replace('/[^0-9]/', '', $cedulaInput);

            $stmt = $pdo->prepare("SELECT c.id_cliente, c.nombres, c.apellidos, cc.id_credencial, cc.password, cc.estado, cc.must_change_password
                               FROM clientes c
                               INNER JOIN clientes_credenciales cc ON cc.id_cliente = c.id_cliente
                               WHERE c.cedula = ?
                                  OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(c.cedula), 'V-', ''), 'E-', ''), 'J-', ''), 'P-', ''), 'G-', '') = ?
                               LIMIT 2");
        $stmt->execute([$cedulaInput, $cleanInput]);
        $matches = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($matches) !== 1) {
            out(['status' => 'error', 'message' => 'Cédula o contraseña incorrectas.'], 401);
        }

        $cliente = $matches[0];
        $cred = $cliente;
        if (isset($cred['estado']) && $cred['estado'] !== 'activa') {
            out(['status' => 'error', 'message' => 'Tu cuenta del portal se encuentra suspendida. Contacta a atención al cliente.'], 403);
        }
        if (!password_verify($password, $cred['password'])) {
            out(['status' => 'error', 'message' => 'Cédula o contraseña incorrectas.'], 401);
        }

        $token = bin2hex(random_bytes(32));
        $expira = date('Y-m-d H:i:s', strtotime('+7 days'));
        $pdo->prepare("INSERT INTO sesiones (token, tipo_usuario, id_credencial, expira_en) VALUES (?, 'cliente', ?, ?)")
            ->execute([$token, $cred['id_credencial'], $expira]);
        $pdo->prepare('UPDATE clientes_credenciales SET ultimo_acceso = NOW() WHERE id_credencial = ?')
            ->execute([$cred['id_credencial']]);

        out([
            'status' => 'success',
            'token' => $token,
            'nombre' => $cliente['nombres'] . ' ' . $cliente['apellidos'],
            'must_change_password' => (int) $cred['must_change_password'] === 1,
        ]);
    }

    /* ------------------- A PARTIR DE AQUÍ: AUTENTICADO ------------------- */
    $auth = requireClientAuth($pdo);
    $idCliente = $auth['id_cliente'];
    $stmtMustChange = $pdo->prepare('SELECT must_change_password FROM clientes_credenciales WHERE id_credencial = ?');
    $stmtMustChange->execute([$auth['id_credencial']]);
    $mustChangePassword = (int) $stmtMustChange->fetchColumn() === 1;
    if ($mustChangePassword && !in_array($action, ['password', 'logout'], true)) {
        out([
            'status' => 'error',
            'must_change_password' => true,
            'message' => 'Debes cambiar la contraseña antes de consultar tu cuenta.',
        ], 403);
    }

    if ($action === 'logout') {
        $token = $_SERVER['HTTP_X_SESSION_TOKEN'] ?? '';
        $pdo->prepare("DELETE FROM sesiones WHERE token = ? AND tipo_usuario = 'cliente'")->execute([$token]);
        out(['status' => 'success']);
    }

    if ($action === 'resumen') {
        $stmt = $pdo->prepare('SELECT id_cliente, nombres, apellidos, cedula, num_telefono, correo FROM clientes WHERE id_cliente = ?');
        $stmt->execute([$idCliente]);
        $cliente = $stmt->fetch(PDO::FETCH_ASSOC);

        $stmt = $pdo->prepare('SELECT s.id_servicio, s.alias, s.estado_comercial, s.direccion_texto,
                           p.nombre AS plan, p.velocidad_bajada_mbps, p.velocidad_subida_mbps,
                           p.tecnologia, p.precio_mensual, p.moneda
                               FROM servicios s INNER JOIN planes p ON p.id_plan = s.id_plan
                               WHERE s.id_cliente = ? ORDER BY s.id_servicio');
        $stmt->execute([$idCliente]);
        $servicios = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->prepare("SELECT f.id_factura, f.id_servicio, s.alias, f.periodo, f.monto, f.fecha_emision, f.fecha_vencimiento, f.estado,
                                      COALESCE((SELECT SUM(pg.monto) FROM pagos pg WHERE pg.id_factura = f.id_factura AND pg.estado = 'validado'), 0) AS pagado,
                                      EXISTS(SELECT 1 FROM pagos pg WHERE pg.id_factura = f.id_factura AND pg.estado = 'pendiente') AS pago_en_revision
                               FROM facturas f INNER JOIN servicios s ON s.id_servicio = f.id_servicio
                               WHERE s.id_cliente = ? ORDER BY f.periodo DESC, f.id_factura DESC");
        $stmt->execute([$idCliente]);
        $facturas = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $saldo = 0.0;
        $proximo = null;
        foreach ($facturas as &$f) {
            $f['saldo'] = max(0, round((float) $f['monto'] - (float) $f['pagado'], 2));
            $f['pago_en_revision'] = (bool) $f['pago_en_revision'];
            if (in_array($f['estado'], ['pendiente', 'vencida', 'parcial'], true)) {
                $saldo += $f['saldo'];
                if ($proximo === null || $f['fecha_vencimiento'] < $proximo) {
                    $proximo = $f['fecha_vencimiento'];
                }
            }
        }
        unset($f);

        $stmt = $pdo->prepare('SELECT pg.id_pago, pg.id_factura, pg.monto, pg.moneda_pago, pg.tasa_cambio,
                          pg.fecha_pago, mp.codigo AS metodo_codigo, mp.nombre AS metodo_nombre,
                          pg.referencia_bancaria, pg.estado
                       FROM pagos pg LEFT JOIN metodos_pago mp ON mp.id_metodo = pg.id_metodo
                       WHERE pg.id_cliente = ? ORDER BY pg.fecha_pago DESC LIMIT 30');
        $stmt->execute([$idCliente]);
        $pagos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->query('SELECT id_metodo, codigo, nombre, requiere_referencia
                     FROM metodos_pago WHERE activo = 1 ORDER BY orden, nombre');
        $metodosPago = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->prepare('SELECT id_ticket, asunto, estado, prioridad, creado_en FROM tickets WHERE id_cliente = ? ORDER BY creado_en DESC LIMIT 30');
        $stmt->execute([$idCliente]);
        $tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $pdo->prepare('SELECT must_change_password FROM clientes_credenciales WHERE id_cliente = ?');
        $stmt->execute([$idCliente]);

        out([
            'status' => 'success',
            'cliente' => $cliente,
            'servicios' => $servicios,
            'facturas' => $facturas,
            'pagos' => $pagos,
            'metodos_pago' => $metodosPago,
            'tickets' => $tickets,
            'saldo_pendiente' => round($saldo, 2),
            'proximo_vencimiento' => $proximo,
            'must_change_password' => (int) $stmt->fetchColumn() === 1,
        ]);
    }

    if ($action === 'pago') {
        $idFactura = (int) ($input['id_factura'] ?? 0);
        $idMetodo = (int) ($input['id_metodo'] ?? 0);
        $referencia = trim((string) ($input['referencia'] ?? ''));
        $montoInput = trim((string) ($input['monto'] ?? ''));
        $monedaPago = (string) ($input['moneda_pago'] ?? 'USD');
        $tasaInput = trim((string) ($input['tasa_cambio'] ?? ''));
        $monto = is_numeric($montoInput) ? (float) $montoInput : 0.0;

        if ($idMetodo <= 0) {
            out(['status' => 'error', 'message' => 'Selecciona un método de pago válido.'], 422);
        }
        $stmt = $pdo->prepare('SELECT codigo, requiere_referencia FROM metodos_pago WHERE id_metodo = ? AND activo = 1');
        $stmt->execute([$idMetodo]);
        $metodo = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$metodo) {
            out(['status' => 'error', 'message' => 'Selecciona un método de pago válido.'], 422);
        }
        if ((int) $metodo['requiere_referencia'] === 1 && $referencia === '') {
            out(['status' => 'error', 'message' => 'Indica el número de referencia de tu pago.'], 422);
        }
        if ($monto <= 0) {
            out(['status' => 'error', 'message' => 'El monto debe ser mayor que cero.'], 422);
        }
        if (!in_array($monedaPago, ['USD', 'VES'], true)) {
            out(['status' => 'error', 'message' => 'Selecciona USD o VES como moneda de pago.'], 422);
        }
        $tasaCambio = $tasaInput !== '' && is_numeric($tasaInput) ? (float) $tasaInput : null;
        if ($monedaPago === 'VES' && ($tasaCambio === null || $tasaCambio <= 0)) {
            out(['status' => 'error', 'message' => 'Indica una tasa de cambio válida para pagos en VES.'], 422);
        }
        if ($monedaPago === 'USD') {
            $tasaCambio = null;
        }

        $comprobante = $_FILES['comprobante'] ?? null;
        if (!is_array($comprobante) || ($comprobante['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            out(['status' => 'error', 'message' => 'Adjunta el comprobante del pago.'], 422);
        }
        if (($comprobante['size'] ?? 0) <= 0 || $comprobante['size'] > 5 * 1024 * 1024) {
            out(['status' => 'error', 'message' => 'El comprobante debe pesar menos de 5 MB.'], 422);
        }
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($comprobante['tmp_name']);
        $extensiones = ['application/pdf' => 'pdf', 'image/jpeg' => 'jpg', 'image/png' => 'png'];
        if (!isset($extensiones[$mime])) {
            out(['status' => 'error', 'message' => 'Usa un comprobante PDF, JPG o PNG.'], 422);
        }

        $stmt = $pdo->prepare('SELECT f.id_factura, f.id_servicio, f.monto, f.estado
                               FROM facturas f INNER JOIN servicios s ON s.id_servicio = f.id_servicio
                               WHERE f.id_factura = ? AND s.id_cliente = ?');
        $stmt->execute([$idFactura, $idCliente]);
        $factura = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$factura) {
            out(['status' => 'error', 'message' => 'Esa factura no existe en tu cuenta.'], 404);
        }
        if (in_array($factura['estado'], ['pagada', 'anulada'], true)) {
            out(['status' => 'error', 'message' => 'Esa factura ya no admite pagos.'], 422);
        }

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM pagos WHERE id_factura = ? AND estado = 'pendiente'");
        $stmt->execute([$idFactura]);
        if ((int) $stmt->fetchColumn() > 0) {
            out(['status' => 'error', 'message' => 'Ya tienes un pago en revisión para esta factura.'], 409);
        }

        $directorio = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'redytelca_uploads' . DIRECTORY_SEPARATOR . 'comprobantes';
        if (!is_dir($directorio) && !mkdir($directorio, 0700, true) && !is_dir($directorio)) {
            out(['status' => 'error', 'message' => 'No se pudo preparar el almacenamiento del comprobante.'], 500);
        }
        $nombreArchivo = bin2hex(random_bytes(16)) . '.' . $extensiones[$mime];
        $rutaArchivo = $directorio . DIRECTORY_SEPARATOR . $nombreArchivo;
        if (!move_uploaded_file($comprobante['tmp_name'], $rutaArchivo)) {
            out(['status' => 'error', 'message' => 'No se pudo guardar el comprobante.'], 500);
        }

        try {
            $stmt = $pdo->prepare("INSERT INTO pagos (id_factura, id_cliente, id_servicio, monto, moneda_pago, tasa_cambio, fecha_pago, id_metodo, referencia_bancaria, comprobante_path, estado, origen)
                                   VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, ?, ?, 'pendiente', 'portal_cliente')");
            $stmt->execute([
                $idFactura,
                $idCliente,
                $factura['id_servicio'],
                $monto,
                $monedaPago,
                $tasaCambio,
                $idMetodo,
                $referencia !== '' ? $referencia : null,
                $nombreArchivo,
            ]);
        } catch (Throwable $exception) {
            if (is_file($rutaArchivo)) {
                unlink($rutaArchivo);
            }
            throw $exception;
        }

        out(['status' => 'success', 'message' => 'Pago reportado. El equipo de REDYTELCA lo validará en breve.']);
    }

    if ($action === 'ticket') {
        $asunto = trim((string) ($input['asunto'] ?? ''));
        $descripcion = trim((string) ($input['descripcion'] ?? ''));
        $idServicio = (int) ($input['id_servicio'] ?? 0);
        if ($asunto === '' || $descripcion === '') {
            out(['status' => 'error', 'message' => 'Completa el asunto y la descripción.'], 422);
        }
        if ($idServicio > 0) {
            $stmt = $pdo->prepare('SELECT COUNT(*) FROM servicios WHERE id_servicio = ? AND id_cliente = ?');
            $stmt->execute([$idServicio, $idCliente]);
            if ((int) $stmt->fetchColumn() === 0) {
                out(['status' => 'error', 'message' => 'Servicio inválido.'], 422);
            }
        }
        $pdo->prepare("INSERT INTO tickets (asunto, descripcion, estado, prioridad, id_cliente, id_servicio)
                       VALUES (?, ?, 'Abierto', 'Media', ?, ?)")
            ->execute([mb_substr($asunto, 0, 150), $descripcion, $idCliente, $idServicio > 0 ? $idServicio : null]);

        out(['status' => 'success', 'message' => 'Ticket creado. Te responderemos pronto.']);
    }

    if ($action === 'password') {
        $actual = (string) ($input['actual'] ?? '');
        $nueva = (string) ($input['nueva'] ?? '');
        $longitudNueva = mb_strlen($nueva, 'UTF-8');
        if ($longitudNueva < 15 || $longitudNueva > 128) {
            out(['status' => 'error', 'message' => 'La nueva contraseña debe tener entre 15 y 128 caracteres.'], 422);
        }
        $stmt = $pdo->prepare('SELECT id_credencial, password FROM clientes_credenciales WHERE id_cliente = ?');
        $stmt->execute([$idCliente]);
        $cred = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$cred || !password_verify($actual, $cred['password'])) {
            out(['status' => 'error', 'message' => 'La contraseña actual no es correcta.'], 401);
        }
        $pdo->prepare('UPDATE clientes_credenciales SET password = ?, must_change_password = 0 WHERE id_credencial = ?')
            ->execute([password_hash($nueva, PASSWORD_DEFAULT), $cred['id_credencial']]);

        out(['status' => 'success', 'message' => 'Contraseña actualizada.']);
    }

    out(['status' => 'error', 'message' => 'Acción no válida.'], 400);
} catch (PDOException $e) {
    out(['status' => 'error', 'message' => 'Error interno al procesar la solicitud.'], 500);
} catch (Throwable $e) {
    out(['status' => 'error', 'message' => 'Error interno al procesar la solicitud.'], 500);
}
