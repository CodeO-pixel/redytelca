<?php

function enviarCorreoVerificacion(string $email, string $username, string $verificationUrl): void {
    $autoload = __DIR__ . '/../vendor/autoload.php';
    if (!is_file($autoload)) {
        throw new RuntimeException('No están instaladas las dependencias de Composer.');
    }
    require_once $autoload;

    $host = trim((string) getenv('SMTP_HOST'));
    $fromEmail = trim((string) getenv('SMTP_FROM_EMAIL'));
    if ($host === '' || $fromEmail === '') {
        throw new RuntimeException('Falta configurar el servidor SMTP o el remitente.');
    }

    $encryption = strtolower(trim((string) (getenv('SMTP_ENCRYPTION') ?: 'tls')));
    $mailer = new PHPMailer\PHPMailer\PHPMailer(true);
    $mailer->isSMTP();
    $mailer->Host = $host;
    $mailer->Port = (int) (getenv('SMTP_PORT') ?: 587);
    $mailer->SMTPAuth = trim((string) getenv('SMTP_USERNAME')) !== '';
    if ($mailer->SMTPAuth) {
        $mailer->Username = (string) getenv('SMTP_USERNAME');
        $mailer->Password = (string) getenv('SMTP_PASSWORD');
    }

    if ($encryption === 'tls') {
        $mailer->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
    } elseif ($encryption === 'ssl') {
        $mailer->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_SMTPS;
    } elseif ($encryption !== 'none') {
        throw new RuntimeException('SMTP_ENCRYPTION debe ser tls, ssl o none.');
    } else {
        $mailer->SMTPAutoTLS = false;
    }

    $mailer->CharSet = 'UTF-8';
    $mailer->setFrom($fromEmail, (string) (getenv('SMTP_FROM_NAME') ?: 'REDYTELCA'));
    $mailer->addAddress($email, $username);
    $mailer->isHTML(true);
    $mailer->Subject = 'Verifica tu correo de REDYTELCA';
    $safeUsername = htmlspecialchars($username, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $safeUrl = htmlspecialchars($verificationUrl, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $mailer->Body = '<p>Hola ' . $safeUsername . ',</p><p>Confirma que tienes acceso a este correo:</p><p><a href="' . $safeUrl . '">Verificar mi correo</a></p><p>El enlace vence en 24 horas.</p>';
    $mailer->AltBody = "Hola {$username},\n\nConfirma que tienes acceso a este correo abriendo este enlace (vence en 24 horas):\n{$verificationUrl}";
    $mailer->send();
}