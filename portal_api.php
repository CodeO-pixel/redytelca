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
 * Acceso inicial: usuario = cédula, clave = cédula (se crea la credencial
 * automáticamente en el primer ingreso y se obliga a cambiar la clave).
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
        $cedula = trim((string) ($input['cedula'] ?? ''));
        $password = (string) ($input['password'] ?? '');
        if ($cedula === '' || $password === '') {
            out(['status' => 'error', 'message' => 'Ingresa tu cédula y tu contraseña.'], 422);
        }

        $stmt = $pdo->prepare('SELECT id_cliente, nombres, apellidos, cedula, correo FROM clientes WHERE cedula = ?');
        $stmt->execute([$cedula]);
        $cliente = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$cliente) {
            out(['status' => 'error', 'message' => 'Cédula o contraseña incorrectos.'], 401);
        }

        $stmt = $pdo->prepare('SELECT * FROM clientes_credenciales WHERE id_cliente = ?');
        $stmt->execute([$cliente['id_cliente']]);
        $cred = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$cred) {
            // Primer ingreso: la clave inicial es la propia cédula.
            $ins = $pdo->prepare('INSERT INTO clientes_credenciales (id_cliente, username, password, correo_recuperacion, must_change_password)
                                  VALUES (?, ?, ?, ?, 1)');
            $ins->execute([
                $cliente['id_cliente'],
                substr($cliente['cedula'], 0, 15),
                password_hash($cliente['cedula'], PASSWORD_DEFAULT),
                $cliente['correo'],
            ]);
            $stmt = $pdo->prepare('SELECT * FROM clientes_credenciales WHERE id_cliente = ?');
            $stmt->execute([$cliente['id_cliente']]);
            $cred = $stmt->fetch(PDO::FETCH_ASSOC);
        }

        if ($cred['estado'] !== 'activa' || !password_verify($password, $cred['password'])) {
            out(['status' => 'error', 'message' => 'Cédula o contraseña incorrectos.'], 401);
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
            'must_change_password' => (int) $cred['must_change_password'] === 1,
            'nombre' => $cliente['nombres'] . ' ' . $cliente['apellidos'],
        ]);
    }

    /* ------------------- A PARTIR DE AQUÍ: AUTENTICADO ------------------- */
    $auth = requireClientAuth($pdo);
    $idCliente = $auth['id_cliente'];

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
                                      p.nombre AS plan, p.velocidad, p.precio_mensual, p.moneda
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

        $stmt = $pdo->prepare('SELECT pg.id_pago, pg.id_factura, pg.monto, pg.fecha_pago, pg.metodo_pago, pg.referencia_bancaria, pg.estado
                               FROM pagos pg WHERE pg.id_cliente = ? ORDER BY pg.fecha_pago DESC LIMIT 30');
        $stmt->execute([$idCliente]);
        $pagos = $stmt->fetchAll(PDO::FETCH_ASSOC);

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
            'tickets' => $tickets,
            'saldo_pendiente' => round($saldo, 2),
            'proximo_vencimiento' => $proximo,
            'must_change_password' => (int) $stmt->fetchColumn() === 1,
        ]);
    }

    if ($action === 'pago') {
        $idFactura = (int) ($input['id_factura'] ?? 0);
        $metodo = (string) ($input['metodo'] ?? '');
        $referencia = trim((string) ($input['referencia'] ?? ''));
        $monto = (float) ($input['monto'] ?? 0);

        if (!in_array($metodo, ['transferencia', 'pago_movil', 'zelle', 'efectivo'], true)) {
            out(['status' => 'error', 'message' => 'Selecciona un método de pago válido.'], 422);
        }
        if ($metodo !== 'efectivo' && $referencia === '') {
            out(['status' => 'error', 'message' => 'Indica el número de referencia de tu pago.'], 422);
        }
        if ($monto <= 0) {
            out(['status' => 'error', 'message' => 'El monto debe ser mayor que cero.'], 422);
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

        $pdo->prepare("INSERT INTO pagos (id_factura, id_cliente, id_servicio, monto, fecha_pago, metodo_pago, referencia_bancaria, estado, origen)
                       VALUES (?, ?, ?, ?, NOW(), ?, ?, 'pendiente', 'portal_cliente')")
            ->execute([$idFactura, $idCliente, $factura['id_servicio'], $monto, $metodo, $referencia !== '' ? $referencia : null]);

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
        if (strlen($nueva) < 6) {
            out(['status' => 'error', 'message' => 'La nueva contraseña debe tener al menos 6 caracteres.'], 422);
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
}
