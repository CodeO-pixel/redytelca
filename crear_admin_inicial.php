<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$username = trim((string) getenv('REDYTELCA_INITIAL_ADMIN_USERNAME'));
$email = trim((string) getenv('REDYTELCA_INITIAL_ADMIN_EMAIL'));
$password = (string) getenv('REDYTELCA_INITIAL_ADMIN_PASSWORD');

if ($username === '' || strlen($username) > 50) {
    fwrite(STDERR, "Define REDYTELCA_INITIAL_ADMIN_USERNAME (1-50 caracteres).\n");
    exit(1);
}

if (filter_var($email, FILTER_VALIDATE_EMAIL) === false || strlen($email) > 100) {
    fwrite(STDERR, "Define REDYTELCA_INITIAL_ADMIN_EMAIL con un correo válido.\n");
    exit(1);
}

if (strlen($password) < 12) {
    fwrite(STDERR, "REDYTELCA_INITIAL_ADMIN_PASSWORD debe tener al menos 12 caracteres.\n");
    exit(1);
}

try {
    require __DIR__ . '/conexion.php';

    $lockName = 'redytelca_initial_admin';
    $lockAcquired = (int) $pdo->query("SELECT GET_LOCK('$lockName', 10)")->fetchColumn() === 1;
    if (!$lockAcquired) {
        throw new RuntimeException('No se pudo bloquear la creación inicial del administrador.');
    }

    try {
        $pdo->beginTransaction();

        $userCount = (int) $pdo->query('SELECT COUNT(*) FROM usuarios')->fetchColumn();
        if ($userCount !== 0) {
            throw new RuntimeException('Ya existen usuarios; el alta inicial solo se permite en una instalación vacía.');
        }

        $roleQuery = $pdo->prepare("SELECT id_rol FROM rol WHERE nombre_rol = 'Administrador' LIMIT 1");
        $roleQuery->execute();
        $roleId = $roleQuery->fetchColumn();
        if ($roleId === false) {
            throw new RuntimeException('Falta el seed RBAC. Importa bd_redytelca_seed.sql antes de crear el administrador.');
        }

        $passwordHash = password_hash($password, PASSWORD_DEFAULT);
        if ($passwordHash === false) {
            throw new RuntimeException('No se pudo generar el hash de la contraseña.');
        }
        $password = '';
        putenv('REDYTELCA_INITIAL_ADMIN_PASSWORD');

        $insertUser = $pdo->prepare(
            "INSERT INTO usuarios (username, password, email, must_change_password, email_verified, estado)\n" .
            "VALUES (?, ?, ?, 0, 1, 'Activo')"
        );
        $insertUser->execute([$username, $passwordHash, $email]);
        $userId = (int) $pdo->lastInsertId();

        $assignRole = $pdo->prepare('INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, ?)');
        $assignRole->execute([$userId, (int) $roleId]);

        $pdo->commit();
        fwrite(STDOUT, "Administrador inicial creado: $username\n");
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $exception;
    } finally {
        $pdo->query("SELECT RELEASE_LOCK('$lockName')");
    }
} catch (Throwable $exception) {
    fwrite(STDERR, "No se pudo crear el administrador: {$exception->getMessage()}\n");
    exit(1);
}
