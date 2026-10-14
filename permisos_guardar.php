<?php
header('Content-Type: application/json; charset=utf-8');
require 'conexion.php';
requirePageAccess($pdo, 'permisos');
requireOperation($pdo, 'permisos', 'editar');

$input = file_get_contents('php://input');
$data = json_decode($input, true);
if (!$data) {
$data = $_POST;
}

$id_rol = isset($data['id_rol']) ? intval($data['id_rol']) : 0;

// Formato esperado: paginas = [ { id_pagina: X, visible: true, permisos: [1,2,3] }, ... ]
$paginas = isset($data['paginas']) && is_array($data['paginas']) ? $data['paginas'] : [];

if ($id_rol <= 0) {
echo json_encode(["status" => "error", "message" => "Rol inválido"]);
exit;
}

$pdo->beginTransaction();
try {
// 1. Asegurar que existe rol_modulo para cada módulo que tenga al menos una página con permiso.
// Y limpiar los permisos previos de este rol.
$stmtRolModulos = $pdo->prepare("SELECT id_rol_modulo, id_modulo FROM rol_modulo WHERE id_rol = ?");
$stmtRolModulos->execute([$id_rol]);
$rolModulos = [];
foreach ($stmtRolModulos->fetchAll(PDO::FETCH_ASSOC) as $rm) {
$rolModulos[(int) $rm['id_modulo']] = (int) $rm['id_rol_modulo'];
}

// Borrar todos los permisos previos del rol
if (!empty($rolModulos)) {
$placeholders = implode(',', array_fill(0, count($rolModulos), '?'));
$stmtDel = $pdo->prepare("DELETE FROM rol_modulo_permiso WHERE id_rol_modulo IN ($placeholders)");
$stmtDel->execute(array_values($rolModulos));
$stmtDelPagina = $pdo->prepare("DELETE FROM rol_modulo_pagina WHERE id_rol_modulo IN ($placeholders)");
$stmtDelPagina->execute(array_values($rolModulos));
}

// 2. Preparar statements para reinsertar
$stmtModuloDePagina = $pdo->prepare("SELECT id_modulo FROM paginas WHERE id_pagina = ?");
$stmtInsRolModulo = $pdo->prepare("INSERT IGNORE INTO rol_modulo (id_rol, id_modulo) VALUES (?, ?)");
$stmtGetRolModuloId = $pdo->prepare("SELECT id_rol_modulo FROM rol_modulo WHERE id_rol = ? AND id_modulo = ?");
$stmtInsVisibilidad = $pdo->prepare("INSERT IGNORE INTO rol_modulo_pagina (id_rol_modulo, id_modulo, id_pagina) VALUES (?, ?, ?)");
$stmtInsPermiso = $pdo->prepare("INSERT IGNORE INTO rol_modulo_permiso (id_rol_modulo, id_modulo, id_pagina, id_permiso) VALUES (?, ?, ?, ?)");

foreach ($paginas as $paginaItem) {
$idPagina = isset($paginaItem['id_pagina']) ? (int) $paginaItem['id_pagina'] : 0;
$visible = isset($paginaItem['visible']) ? (bool) $paginaItem['visible'] : true;
$permisos = isset($paginaItem['permisos']) && is_array($paginaItem['permisos']) ? $paginaItem['permisos'] : [];

if ($idPagina <= 0 || (!$visible && empty($permisos))) {
continue;
}

// Resolver módulo de la página
$stmtModuloDePagina->execute([$idPagina]);
$idModulo = $stmtModuloDePagina->fetchColumn();
if ($idModulo === false) {
continue;
}
$idModulo = (int) $idModulo;

// Asegurar rol_modulo
if (!isset($rolModulos[$idModulo])) {
$stmtInsRolModulo->execute([$id_rol, $idModulo]);
$stmtGetRolModuloId->execute([$id_rol, $idModulo]);
$idRolModulo = (int) $stmtGetRolModuloId->fetchColumn();
$rolModulos[$idModulo] = $idRolModulo;
}
$idRolModulo = $rolModulos[$idModulo];

if ($visible) {
$stmtInsVisibilidad->execute([$idRolModulo, $idModulo, $idPagina]);
}

// Los permisos se insertan SIEMPRE (independiente de visible).
// Esto preserva los permisos inertes al desmarcar "Ver": quedan en BD
// pero requirePageAccess rechaza antes de llegar a requireOperation.
foreach ($permisos as $idPermisoRaw) {
$idPermiso = (int) $idPermisoRaw;
if ($idPermiso <= 0) {
continue;
}
$stmtInsPermiso->execute([$idRolModulo, $idModulo, $idPagina, $idPermiso]);
}
}

$pdo->commit();
echo json_encode(["status" => "success", "message" => "Permisos actualizados correctamente"]);
} catch (Exception $e) {
if ($pdo->inTransaction()) {
$pdo->rollBack();
}
http_response_code(500);
echo json_encode(["status" => "error", "message" => "Error guardando permisos: " . $e->getMessage()]);
}
// Corrección Grupo D: se reemplaza requireStaffAuth($pdo, 1) por
// requireOperation($pdo, 'permisos', 'editar'). La página 'permisos'
// corresponde a Configuración > Módulos y permisos en el catálogo
// de paginas. El acceso lo decide la matriz de permisos
// (rol_modulo_permiso) en lugar del id_rol.