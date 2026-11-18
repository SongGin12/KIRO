<?php
/**
 * KIRO Admin - Cierre de sesión administrativa
 * Solo por POST con CSRF.
 */

declare(strict_types=1);

$raiz = dirname(__DIR__, 2);
require $raiz . '/app/src/helpers.php';
require $raiz . '/app/src/Database.php';
require $raiz . '/app/src/SesionAdmin.php';
require $raiz . '/app/src/RepositorioAdmin.php';

$rutaConfig = $raiz . '/app/config/config.php';
$config = require $rutaConfig;
date_default_timezone_set($config['app']['zona_horaria'] ?? 'America/La_Paz');
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', $raiz . '/storage/logs/error.log');
mb_internal_encoding('UTF-8');

$cnfAdmin = require $raiz . '/storage/secretos/admin.cnf.php';

SesionAdmin::iniciar();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php', true, 303);
    exit;
}

if (!SesionAdmin::csrfValido($_POST['csrf'] ?? null)) {
    http_response_code(400);
    echo 'Solicitud de cierre de sesión inválida.';
    exit;
}

$idAdmin = SesionAdmin::adminId();
if ($idAdmin !== null) {
    try {
        $pdo = new PDO(
            sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
                $cnfAdmin['host'], (int)$cnfAdmin['puerto'], $cnfAdmin['nombre']),
            $cnfAdmin['usuario'], $cnfAdmin['clave'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
             PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
             PDO::ATTR_EMULATE_PREPARES => false]
        );
        $pdo->exec("SET time_zone = '-04:00'");
        $repo = new RepositorioAdmin($pdo);
        $repo->registrarAccion($idAdmin, 'LOGOUT', 'ADMINISTRADOR', $idAdmin, 'OK', 'Cierre de sesión normal');
    } catch (Throwable $e) {
        error_log('[KIRO][ADMIN] Error en logout: ' . $e->getMessage());
    }
}

SesionAdmin::cerrar();
header('Location: login.php?salida=1', true, 303);
exit;
