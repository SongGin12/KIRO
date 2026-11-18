<?php
/**
 * KIRO Admin - Lista de usuarios
 * kiro_admin lee: id, nombre, correo, fecha_registro de USUARIO.
 * kiro_auth lee hash_contrasena para determinar estado de activación.
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

$titulo       = 'Usuarios';
$paginaActiva = 'usuarios';

try {
    // Conexión administrativa para leer datos públicos
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

    // Detectar estado de activación con kiro_auth (lee hash_contrasena)
    $idsActivos = [];
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
            "SELECT id_usuario FROM USUARIO
              WHERE hash_contrasena LIKE '\$2y\$%'
                 OR hash_contrasena LIKE '\$2a\$%'
                 OR hash_contrasena LIKE '\$2b\$%'
                 OR hash_contrasena LIKE '\$argon2%'"
        );
        $idsActivos = array_map('intval', $stA->fetchAll(PDO::FETCH_COLUMN));
    } catch (Throwable $e) {
        error_log('[KIRO][ADMIN] Estado hash no determinable: ' . $e->getMessage());
    }

    foreach ($usuarios as &$u) {
        $u['estado_activacion'] = in_array((int)$u['id_usuario'], $idsActivos, true)
            ? 'activo'
            : 'pendiente';
    }
    unset($u);

} catch (Throwable $e) {
    error_log('[KIRO][ADMIN] ' . $e->getMessage());
    $usuarios = [];
}

ob_start();
require $raiz . '/app/views/admin/usuarios.php';
$contenido = ob_get_clean();

require $raiz . '/app/views/admin/layout.php';
