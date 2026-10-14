<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
$staffSession = requirePageAccess($pdo, 'pagos');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET' && isset($_GET['comprobante'])) {
    requireOperation($pdo, 'pagos', 'leer');
    $idPago = filter_var($_GET['comprobante'], FILTER_VALIDATE_INT);
    if (!$idPago || $idPago < 1) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Pago inválido.']);
        exit;
    }

    $stmt = $pdo->prepare('SELECT comprobante_path FROM pagos WHERE id_pago = ?');
    $stmt->execute([$idPago]);
    $nombreArchivo = $stmt->fetchColumn();
    if (!is_string($nombreArchivo) || !preg_match('/^[a-f0-9]{32}\.(pdf|jpg|png)$/', $nombreArchivo)) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'No hay comprobante para este pago.']);
        exit;
    }

    $directorio = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'redytelca_uploads' . DIRECTORY_SEPARATOR . 'comprobantes';
    $rutaArchivo = $directorio . DIRECTORY_SEPARATOR . $nombreArchivo;
    if (!is_file($rutaArchivo)) {
        http_response_code(404);
        echo json_encode(['status' => 'error', 'message' => 'El comprobante no está disponible.']);
        exit;
    }

    $mimePorExtension = ['pdf' => 'application/pdf', 'jpg' => 'image/jpeg', 'png' => 'image/png'];
    $extension = pathinfo($nombreArchivo, PATHINFO_EXTENSION);
    header('Content-Type: ' . $mimePorExtension[$extension]);
    header('Content-Disposition: inline; filename="comprobante-' . $idPago . '.' . $extension . '"');
    header('Content-Length: ' . filesize($rutaArchivo));
    header('X-Content-Type-Options: nosniff');
    readfile($rutaArchivo);
    exit;
}

/**
 * Reconciliación de estado de factura (Parte 4.5 del documento maestro):
 * suma de pagos validados vs. monto de la factura ->
 *   >= monto  => 'pagada'
 *   > 0       => 'parcial'
 *   = 0       => vuelve a 'pendiente' (nunca revierte una 'anulada' manual)
 * Se ejecuta en PHP, no como trigger de BD, consistente con el patrón de
 * lógica de negocio en capa de aplicación que ya usa el resto del proyecto.
 */
function reconciliarFactura(PDO $pdo, ?int $idFactura): void {
    if (!$idFactura) {
        return;
    }

    $stmtFactura = $pdo->prepare("SELECT monto, estado FROM facturas WHERE id_factura = ?");
    $stmtFactura->execute([$idFactura]);
    $factura = $stmtFactura->fetch(PDO::FETCH_ASSOC);
    if (!$factura || $factura['estado'] === 'anulada') {
        return;
    }

    $stmtSuma = $pdo->prepare("SELECT COALESCE(SUM(monto), 0) FROM pagos WHERE id_factura = ? AND estado = 'validado'");
    $stmtSuma->execute([$idFactura]);
    $totalPagado = (float) $stmtSuma->fetchColumn();
    $monto = (float) $factura['monto'];

    if ($totalPagado >= $monto && $monto > 0) {
        $nuevoEstado = 'pagada';
    } elseif ($totalPagado > 0) {
        $nuevoEstado = 'parcial';
    } else {
        // No revertir 'vencida' automáticamente aquí; el recalculo de
        // vencimiento vive en api_facturas.php y corre en cada GET de
        // facturas. Solo evitamos dejarla en 'pagada'/'parcial' huérfana.
        $nuevoEstado = ($factura['estado'] === 'vencida') ? 'vencida' : 'pendiente';
    }

    $stmtUpdate = $pdo->prepare("UPDATE facturas SET estado = ? WHERE id_factura = ?");
    $stmtUpdate->execute([$nuevoEstado, $idFactura]);
}

if ($method === 'GET') {
    requireOperation($pdo, 'pagos', 'leer');
    $stmt = $pdo->query("SELECT pg.*,
                                c.nombres, c.apellidos, c.cedula,
                                s.direccion_texto,
                                f.periodo AS factura_periodo, f.monto AS factura_monto, f.estado AS factura_estado,
                                u.username AS validado_por,
                                mp.codigo AS metodo_codigo, mp.nombre AS metodo_nombre
                         FROM pagos pg
                         INNER JOIN clientes c ON c.id_cliente = pg.id_cliente
                         INNER JOIN servicios s ON s.id_servicio = pg.id_servicio
                         LEFT JOIN facturas f ON f.id_factura = pg.id_factura
                         LEFT JOIN usuarios u ON u.id_usuario = pg.id_usuario_valido
                         LEFT JOIN metodos_pago mp ON mp.id_metodo = pg.id_metodo
                         ORDER BY pg.fecha_pago DESC");
    echo json_encode(['status' => 'success', 'pagos' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    $input = $_POST;
}

if ($method === 'POST') {
    requireOperation($pdo, 'pagos', 'crear');
    $id_factura = isset($input['id_factura']) && $input['id_factura'] !== '' ? (int)$input['id_factura'] : null;
    $id_cliente = (int)($input['id_cliente'] ?? 0);
    $id_servicio = (int)($input['id_servicio'] ?? 0);
    $monto = isset($input['monto']) && $input['monto'] !== '' ? (float)$input['monto'] : null;
    $fecha_pago = trim($input['fecha_pago'] ?? '');
    $id_metodo = isset($input['id_metodo']) && $input['id_metodo'] !== '' ? (int)$input['id_metodo'] : null;
    $referencia_bancaria = trim($input['referencia_bancaria'] ?? '');
    $moneda_pago = trim($input['moneda_pago'] ?? 'USD');
    if (!in_array($moneda_pago, ['USD', 'VES'], true)) {
        $moneda_pago = 'USD';
    }
    $tasa_cambio = isset($input['tasa_cambio']) ? ($input['tasa_cambio'] !== '' ? (float)$input['tasa_cambio'] : null) : null;
    if ($moneda_pago === 'VES' && ($tasa_cambio === null || $tasa_cambio <= 0)) {
        echo json_encode(['status' => 'error', 'message' => 'Si la moneda de pago es VES, la tasa de cambio es obligatoria y debe ser mayor a 0.']);
        exit;
    }
    if ($moneda_pago === 'USD') {
        $tasa_cambio = null;
    }
    $comprobante_path = trim($input['comprobante_path'] ?? '');
    if ($comprobante_path === '') {
        $comprobante_path = null;
    }
    $motivo_rechazo = trim($input['motivo_rechazo'] ?? '');
    if ($motivo_rechazo === '') {
        $motivo_rechazo = null;
    }
    // Todo pago creado desde el backoffice nace 'pendiente' por defecto,
    // igual que uno creado desde el futuro portal de cliente (Fase 5):
    // la validación es siempre un acto explícito y posterior de Admin.
    $estado = 'pendiente';
    $origen = trim($input['origen'] ?? 'backoffice');
    if (!in_array($origen, ['portal_cliente', 'backoffice'], true)) {
        $origen = 'backoffice';
    }

    if ($id_cliente <= 0 || $id_servicio <= 0 || $monto === null || $monto <= 0 || $fecha_pago === '') {
        echo json_encode(['status' => 'error', 'message' => 'Cliente, servicio, monto y fecha de pago son obligatorios']);
        exit;
    }

    if ($id_metodo !== null) {
        $stmtMp = $pdo->prepare("SELECT id_metodo FROM metodos_pago WHERE id_metodo = ? AND activo = 1");
        $stmtMp->execute([$id_metodo]);
        if (!$stmtMp->fetch()) {
            echo json_encode(['status' => 'error', 'message' => 'El método de pago seleccionado no es válido o está inactivo.']);
            exit;
        }
    }

    try {
        $stmt = $pdo->prepare("INSERT INTO pagos (id_factura, id_cliente, id_servicio, monto, fecha_pago, id_metodo, referencia_bancaria, moneda_pago, tasa_cambio, comprobante_path, motivo_rechazo, estado, origen)
                                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $ok = $stmt->execute([
            $id_factura,
            $id_cliente,
            $id_servicio,
            $monto,
            $fecha_pago,
            $id_metodo,
            $referencia_bancaria ?: null,
            $moneda_pago,
            $tasa_cambio,
            $comprobante_path,
            $motivo_rechazo,
            $estado,
            $origen
        ]);
        echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Pago registrado correctamente, pendiente de validación' : 'No se pudo registrar el pago']);    } catch (PDOException $e) {
        $sqlCode = (int) ($e->errorInfo[1] ?? 0);
        if ($sqlCode === 1452) {
            echo json_encode(['status' => 'error', 'message' => 'El cliente, servicio o factura seleccionados no son válidos.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al registrar el pago. Contacta al administrador si persiste.']);
        }
    }
    exit;
}

if ($method === 'PUT') {
    requireOperation($pdo, 'pagos', 'editar');
    $id = (int)($input['id_pago'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Pago inválido']);
        exit;
    }

    $stmtActual = $pdo->prepare("SELECT * FROM pagos WHERE id_pago = ?");
    $stmtActual->execute([$id]);
    $pagoActual = $stmtActual->fetch(PDO::FETCH_ASSOC);
    if (!$pagoActual) {
        echo json_encode(['status' => 'error', 'message' => 'El pago ya no existe.']);
        exit;
    }

    $nuevoEstado = trim($input['estado'] ?? $pagoActual['estado']);
    $estadosValidos = ['pendiente', 'validado', 'rechazado'];
    if (!in_array($nuevoEstado, $estadosValidos, true)) {
        $nuevoEstado = $pagoActual['estado'];
    }

    $estadosSensibles = ['validado', 'rechazado', 'pendiente'];
    $cambioDeEstadoSensible = $nuevoEstado !== $pagoActual['estado'] && in_array($nuevoEstado, $estadosSensibles, true);

    // PROMPT 14: la visibilidad del módulo Pagos ya es configurable por el
    // Admin vía rol_modulo_pagina (ver requirePageAccess() en el gate de
    // entrada), pero validar/rechazar un pago sigue siendo una acción de
    // negocio reservada exclusivamente al Administrador (Parte 4.7 del
    // documento maestro: "finanzas.validar" no se modela como página, se
    // resuelve verificando roleId===1 explícitamente). Un Operador con la
    // página Pagos habilitada puede listar/crear/editar campos no
    // sensibles, pero nunca puede mover el estado a validado/rechazado.
    if ($cambioDeEstadoSensible && !in_array(1, $staffSession['roles'], true)) {
        http_response_code(403);
        echo json_encode(['status' => 'error', 'message' => 'Solo un Administrador puede validar o rechazar un pago.']);
        exit;
    }

    $id_factura = isset($input['id_factura']) && $input['id_factura'] !== '' ? (int)$input['id_factura'] : null;
    $id_cliente = (int) $pagoActual['id_cliente'];
    $id_servicio = (int) $pagoActual['id_servicio'];
    $monto = isset($input['monto']) && $input['monto'] !== '' ? (float)$input['monto'] : (float)$pagoActual['monto'];
    $fecha_pago = trim($input['fecha_pago'] ?? $pagoActual['fecha_pago']);
    $id_metodo = array_key_exists('id_metodo', $input)
        ? ($input['id_metodo'] !== '' ? (int)$input['id_metodo'] : null)
        : ($pagoActual['id_metodo'] !== null ? (int)$pagoActual['id_metodo'] : null);
    $referencia_bancaria = trim($input['referencia_bancaria'] ?? ($pagoActual['referencia_bancaria'] ?? ''));
    $moneda_pago = trim($input['moneda_pago'] ?? ($pagoActual['moneda_pago'] ?? 'USD'));
    if (!in_array($moneda_pago, ['USD', 'VES'], true)) {
        $moneda_pago = 'USD';
    }
    if (array_key_exists('tasa_cambio', $input)) {
        $tasa_cambio = $input['tasa_cambio'] !== '' ? (float)$input['tasa_cambio'] : null;
    } else {
        $tasa_cambio = $pagoActual['tasa_cambio'] !== null ? (float)$pagoActual['tasa_cambio'] : null;
    }
    if ($moneda_pago === 'VES' && ($tasa_cambio === null || $tasa_cambio <= 0)) {
        echo json_encode(['status' => 'error', 'message' => 'Si la moneda de pago es VES, la tasa de cambio es obligatoria y debe ser mayor a 0.']);
        exit;
    }
    if ($moneda_pago === 'USD') {
        $tasa_cambio = null;
    }
    $comprobante_path = trim($input['comprobante_path'] ?? ($pagoActual['comprobante_path'] ?? ''));
    if ($comprobante_path === '') {
        $comprobante_path = null;
    }
    $motivo_rechazo = trim($input['motivo_rechazo'] ?? ($pagoActual['motivo_rechazo'] ?? ''));
    if ($motivo_rechazo === '') {
        $motivo_rechazo = null;
    }

    if ($id_metodo !== null) {
        $stmtMp = $pdo->prepare("SELECT id_metodo FROM metodos_pago WHERE id_metodo = ? AND activo = 1");
        $stmtMp->execute([$id_metodo]);
        if (!$stmtMp->fetch()) {
            echo json_encode(['status' => 'error', 'message' => 'El método de pago seleccionado no es válido o está inactivo.']);
            exit;
        }
    }

    $pdo->beginTransaction();
    try {
        if ($cambioDeEstadoSensible) {
            $idUsuarioValido = $staffSession['id_usuario'];
            $stmt = $pdo->prepare("UPDATE pagos SET id_factura = ?, id_cliente = ?, id_servicio = ?, monto = ?, fecha_pago = ?, id_metodo = ?, referencia_bancaria = ?, moneda_pago = ?, tasa_cambio = ?, comprobante_path = ?, motivo_rechazo = ?, estado = ?, fecha_validacion = NOW(), id_usuario_valido = ? WHERE id_pago = ?");
            $stmt->execute([$id_factura, $id_cliente, $id_servicio, $monto, $fecha_pago, $id_metodo, $referencia_bancaria ?: null, $moneda_pago, $tasa_cambio, $comprobante_path, $motivo_rechazo, $nuevoEstado, $idUsuarioValido, $id]);
        } else {
            if (in_array(1, $staffSession['roles'], true)) {
                $stmt = $pdo->prepare("UPDATE pagos SET id_factura = ?, id_cliente = ?, id_servicio = ?, monto = ?, fecha_pago = ?, id_metodo = ?, referencia_bancaria = ?, moneda_pago = ?, tasa_cambio = ?, comprobante_path = ?, motivo_rechazo = ?, estado = ? WHERE id_pago = ?");
                $stmt->execute([$id_factura, $id_cliente, $id_servicio, $monto, $fecha_pago, $id_metodo, $referencia_bancaria ?: null, $moneda_pago, $tasa_cambio, $comprobante_path, $motivo_rechazo, $nuevoEstado, $id]);
            } else {
                $stmt = $pdo->prepare("UPDATE pagos SET id_metodo = ?, referencia_bancaria = ?, comprobante_path = ?, motivo_rechazo = ?, estado = ? WHERE id_pago = ?");
                $stmt->execute([$id_metodo, $referencia_bancaria ?: null, $comprobante_path, $motivo_rechazo, $nuevoEstado, $id]);
            }
        }

        // Reconciliar tanto la factura anterior (si el pago se reasignó a
        // otra factura) como la nueva, para no dejar la vieja con un total
        // desfasado.
        if ($pagoActual['id_factura'] && $pagoActual['id_factura'] != $id_factura) {
            reconciliarFactura($pdo, (int) $pagoActual['id_factura']);
        }
        reconciliarFactura($pdo, $id_factura);

        $pdo->commit();
        echo json_encode(['status' => 'success', 'message' => 'Pago actualizado correctamente']);
    } catch (PDOException $e) {
        $pdo->rollBack();
        $sqlCode = (int) ($e->errorInfo[1] ?? 0);
        if ($sqlCode === 1452) {
            echo json_encode(['status' => 'error', 'message' => 'El cliente, servicio o factura seleccionados no son válidos.']);
        } elseif ($sqlCode === 1644) {
            echo json_encode(['status' => 'error', 'message' => $e->errorInfo[2] ?: 'La transición de estado no es válida para este pago.']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error al actualizar el pago. Contacta al administrador si persiste.']);
        }
    } catch (Exception $e) {
        $pdo->rollBack();
        echo json_encode(['status' => 'error', 'message' => 'Error al actualizar el pago. Contacta al administrador si persiste.']);
    }
    exit;
}

if ($method === 'DELETE') {
    requireOperation($pdo, 'pagos', 'eliminar');
    $id = (int)($_GET['id'] ?? 0);
    if ($id <= 0) {
        echo json_encode(['status' => 'error', 'message' => 'Pago inválido']);
        exit;
    }

    $stmtActual = $pdo->prepare("SELECT id_factura, estado FROM pagos WHERE id_pago = ?");
    $stmtActual->execute([$id]);
    $pagoActual = $stmtActual->fetch(PDO::FETCH_ASSOC);
    if (!$pagoActual) {
        echo json_encode(['status' => 'error', 'message' => 'El pago ya no existe.']);
        exit;
    }

    // Un pago ya validado no se elimina físicamente: rompería la
    // trazabilidad contable. La vía correcta es rechazarlo (PUT estado='rechazado') si fue un error.
    if ($pagoActual['estado'] === 'validado') {
        echo json_encode(['status' => 'error', 'message' => 'No se puede eliminar un pago ya validado. Márcalo como rechazado si fue un error, para preservar la trazabilidad contable.']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("DELETE FROM pagos WHERE id_pago = ?");
        $ok = $stmt->execute([$id]);
        if ($ok && $pagoActual['id_factura']) {
            reconciliarFactura($pdo, (int) $pagoActual['id_factura']);
        }
        echo json_encode(['status' => $ok ? 'success' : 'error', 'message' => $ok ? 'Pago eliminado' : 'No se pudo eliminar']);
    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Error al eliminar el pago. Contacta al administrador si persiste.']);
    }
    exit;
}

echo json_encode(['status' => 'error', 'message' => 'Método no soportado']);
// Corrección: `id_usuario_valido` ahora se toma de la sesión autenticada
// del administrador que ya pasó `requireStaffAuth($pdo, 1)`, evitando que
// el body HTTP manipule la auditoría del pago en la columna financiera.

// ============================================================================
// CAMBIOS APLICADOS EN ESTA REVISIÓN
// ============================================================================
// 1. BUG 1 (AUD-2026-B05): Se incluyó 'pendiente' en $estadosSensibles para evitar que un no-admin revierta pagos validados.
// 2. BUG 2 (AUD-2026-B23): $id_cliente e $id_servicio ahora se toman siempre de $pagoActual, ignorando el body HTTP.
// 3. BUG 3 (AUD-2026-B26): En la rama no-sensible, se restringió la actualización de campos financieros (monto, factura, etc.) solo para administradores.
// 4. BUG 4 (AUD-2026-B10): Se eliminó la fuga de información de $e->getMessage() en los bloques catch de POST, PUT y DELETE.
// ============================================================================