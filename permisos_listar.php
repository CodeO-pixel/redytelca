<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'permisos');
requireOperation($pdo, 'permisos', 'leer');

$id_rol = isset($_GET['id_rol']) ? intval($_GET['id_rol']) : 0;

// Catálogo completo de permisos (leer, crear, editar, eliminar, validar)
$stmtPermisos = $pdo->query("SELECT id_permiso, nombre FROM permisos ORDER BY id_permiso");
$permisosCatalogo = $stmtPermisos->fetchAll(PDO::FETCH_ASSOC);

// Nivel 1 — Visibilidad (RBAC dos niveles).
// Páginas que el rol puede VER. Fuente: rol_modulo_pagina.
// Independiente de los permisos de operación (nivel 2).
$visibles = [];
if ($id_rol > 0) {
    $stmtVis = $pdo->prepare("
        SELECT rmpag.id_pagina
        FROM rol_modulo_pagina rmpag
        INNER JOIN rol_modulo rm ON rm.id_rol_modulo = rmpag.id_rol_modulo
        WHERE rm.id_rol = ?
    ");
    $stmtVis->execute([$id_rol]);
    foreach ($stmtVis->fetchAll(PDO::FETCH_COLUMN, 0) as $idPag) {
        $visibles[(int) $idPag] = true;
    }
}

// Permisos ya asignados al rol: mapa [id_pagina][id_permiso] = true
$asignados = [];
if ($id_rol > 0) {
    $stmtAsig = $pdo->prepare("
        SELECT rmp.id_pagina, rmp.id_permiso
        FROM rol_modulo_permiso rmp
        INNER JOIN rol_modulo rm ON rm.id_rol_modulo = rmp.id_rol_modulo
        WHERE rm.id_rol = ?
    ");
    $stmtAsig->execute([$id_rol]);
    foreach ($stmtAsig->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $idPag = (int) $row['id_pagina'];
        $idPer = (int) $row['id_permiso'];
        if (!isset($asignados[$idPag])) {
            $asignados[$idPag] = [];
        }
        $asignados[$idPag][$idPer] = true;
    }
}

// Universo completo de módulos/páginas
$stmt = $pdo->query("SELECT m.id_modulo, m.nombre_modulo, p.id_pagina, p.nombre_pagina, p.url_pagina
    FROM modulos m
    INNER JOIN paginas p ON p.id_modulo = m.id_modulo
    ORDER BY m.id_modulo, p.id_pagina");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

$modulos = [];
foreach ($rows as $row) {
    $idModulo = (int) $row['id_modulo'];
    if (!isset($modulos[$idModulo])) {
        $modulos[$idModulo] = [
            'id_modulo' => $idModulo,
            'nombre_modulo' => $row['nombre_modulo'],
            'vistas' => []
        ];
    }
    $idPagina = (int) $row['id_pagina'];

    // Permisos asignados a esta página para este rol
    $permisosPagina = [];
    foreach ($permisosCatalogo as $perm) {
        $idPer = (int) $perm['id_permiso'];
        $permisosPagina[] = [
            'id_permiso' => $idPer,
            'nombre' => $perm['nombre'],
            'asignado' => isset($asignados[$idPagina][$idPer])
        ];
    }

    $modulos[$idModulo]['vistas'][] = [
        'id_pagina' => $idPagina,
        'nombre_pagina' => $row['nombre_pagina'],
        'url_pagina' => $row['url_pagina'],
        'visible' => isset($visibles[$idPagina]),
        'permisos' => $permisosPagina
    ];
}

echo json_encode([
    'status' => 'success',
    'modulos' => array_values($modulos),
    'permisos_catalogo' => $permisosCatalogo
]);