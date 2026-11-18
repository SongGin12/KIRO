<?php
/**
 * KIRO Admin - Panel principal (index)
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

$titulo       = 'Panel';
$paginaActiva = 'panel';

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

    $usuarios = $repo->listaUsuarios();
    $totalUsuarios = count($usuarios);

    $activos = 0;
    $pendientes = 0;
    try {
        $pdoAuth = new PDO(
            sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
                $config['auth']['host'], (int)$config['auth']['puerto'], $config['auth']['nombre']),
            $config['auth']['usuario'], $config['auth']['clave'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
             PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
             PDO::ATTR_EMULATE_PREPARES => false]
        );
        $pdoAuth->exec("SET time_zone = '-04:00'");
        $stA = $pdoAuth->query(
            "SELECT COUNT(*) FROM USUARIO
              WHERE hash_contrasena LIKE '\$2y\$%'
                 OR hash_contrasena LIKE '\$2a\$%'
                 OR hash_contrasena LIKE '\$2b\$%'
                 OR hash_contrasena LIKE '\$argon2%'"
        );
        $activos = (int)$stA->fetchColumn();
        $pendientes = max(0, $totalUsuarios - $activos);
    } catch (Throwable $e) {
        error_log('[KIRO][ADMIN] Conteo auth falló: ' . $e->getMessage());
    }

    // Acciones hoy
    $hoy = date('Y-m-d');
    $stHoy = $pdo->prepare(
        "SELECT COUNT(*) FROM ACCION_ADMIN WHERE DATE(fecha) = :hoy"
    );
    $stHoy->execute([':hoy' => $hoy]);
    $accionesHoy = (int)$stHoy->fetchColumn();

    $stats = [
        'total_usuarios'      => $totalUsuarios,
        'usuarios_activos'    => $activos,
        'usuarios_pendientes' => $pendientes,
        'acciones_hoy'        => $accionesHoy,
    ];

    $ultimasAcciones = $repo->ultimasAcciones(8);

} catch (Throwable $e) {
    error_log('[KIRO][ADMIN] ' . $e->getMessage());
    $stats           = ['total_usuarios' => 0, 'usuarios_activos' => 0, 'usuarios_pendientes' => 0, 'acciones_hoy' => 0];
    $ultimasAcciones = [];
}

ob_start();
require $raiz . '/app/views/admin/panel.php';
$contenido = ob_get_clean();

require $raiz . '/app/views/admin/layout.php';
