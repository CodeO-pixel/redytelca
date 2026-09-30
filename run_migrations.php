<?php
require 'conexion.php';

// NOTA: este script apuntaba antes a "migrations/002_rbac_dinamico_seed.sql",
// un archivo que nunca llegó a incluirse en el proyecto (probablemente el
// causante de uno de los errores reportados por el profesor: cualquier
// intento de ejecutar este script fallaba con "archivo no encontrado").
// bd_redytelca.sql ya incluye el esquema completo (rol, permissions,
// role_permission, rol_modulo_pagina, etc.), así que en una instalación
// nueva este script es opcional; se deja apuntando a la única migración
// que sí existe (001_create_rbac_tables.sql), que es idempotente
// (CREATE TABLE IF NOT EXISTS / INSERT IGNORE) y por tanto segura de
// re-ejecutar incluso si esas tablas ya existen.
try {
    $sql = file_get_contents(__DIR__ . '/migrations/001_create_rbac_tables.sql');
    if ($sql === false) {
        throw new Exception('No se encontró el archivo de migración 001_create_rbac_tables.sql');
    }

    // NOTA TÉCNICA: PDO::exec() con múltiples sentencias separadas por ';'
    // depende de que el driver tolere multi-statement. conexion.php no
    // habilita PDO::MYSQL_ATTR_MULTI_STATEMENTS explícitamente, así que si
    // este exec() falla a mitad de camino, la alternativa segura es pegar
    // el contenido de migrations/002_rbac_dinamico_seed.sql directamente
    // en la pestaña SQL de phpMyAdmin.
    $pdo->exec($sql);
    echo "Migración 001 (tablas RBAC) ejecutada correctamente\n";

    $sql = file_get_contents(__DIR__ . '/migrations/002_email_verification_tokens.sql');
    if ($sql === false) {
        throw new Exception('No se encontró la migración 002_email_verification_tokens.sql');
    }
    $pdo->exec($sql);
    echo "Migración 002 (tokens de verificación de correo) ejecutada correctamente\n";
} catch (Exception $e) {
    echo "Error ejecutando migraciones: " . $e->getMessage() . "\n";
    exit(1);
}