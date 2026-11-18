<?php
/**
 * KIRO Admin - Bitácora completa de acciones
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
error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', $raiz . '/storage/logs/error.log');
mb_internal_encoding('UTF-8');

$cnfAdmin = require $raiz . '/storage/secretos/admin.cnf.php';

SesionAdmin::iniciar();
SesionAdmin::exigirAdmin();

$titulo       = 'Bitácora';
$paginaActiva = 'bitacora';

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
    $acciones = $repo->ultimasAcciones(100);
} catch (Throwable $e) {
    error_log('[KIRO][ADMIN] ' . $e->getMessage());
    $acciones = [];
}

ob_start();
require $raiz . '/app/views/admin/bitacora.php';
$contenido = ob_get_clean();

require $raiz . '/app/views/admin/layout.php';
