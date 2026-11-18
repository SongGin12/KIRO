<?php
/**
 * KIRO Admin - Login administrativo
 * Accede a la tabla ADMINISTRADOR (separada de USUARIO).
 * Usa SesionAdmin, que nombra la cookie KIRO_ADMIN_SESION.
 */

declare(strict_types=1);

$raiz = dirname(__DIR__, 2);

require $raiz . '/app/src/helpers.php';
require $raiz . '/app/src/Database.php';
require $raiz . '/app/src/SesionAdmin.php';
require $raiz . '/app/src/RepositorioAdmin.php';

$rutaConfig = $raiz . '/app/config/config.php';
if (!is_file($rutaConfig)) {
    http_response_code(500);
    echo 'Falta app/config/config.php';
    exit;
}
$config = require $rutaConfig;

date_default_timezone_set($config['app']['zona_horaria'] ?? 'America/La_Paz');
error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', $raiz . '/storage/logs/error.log');
mb_internal_encoding('UTF-8');

// Cargar las credenciales de kiro_admin
$cnfAdmin = require $raiz . '/storage/secretos/admin.cnf.php';

SesionAdmin::iniciar();

if (SesionAdmin::autenticado()) {
    header('Location: index.php', true, 303);
    exit;
}

$errores = [];
$correo  = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $correo = mb_strtolower(trim((string)($_POST['correo'] ?? '')), 'UTF-8');
    $clave  = (string)($_POST['clave'] ?? '');

    if (!SesionAdmin::csrfValido($_POST['csrf'] ?? null)) {
        $errores[] = 'Formulario inválido. Vuelve a intentarlo.';
    }
    if ($correo === '' || !filter_var($correo, FILTER_VALIDATE_EMAIL)) {
        $errores[] = 'Correo electrónico inválido.';
    }
    if ($clave === '') {
        $errores[] = 'Escribe la contraseña.';
    }

    if ($errores === []) {
        try {
            $pdo  = new PDO(
                sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
                    $cnfAdmin['host'], (int)$cnfAdmin['puerto'], $cnfAdmin['nombre']),
                $cnfAdmin['usuario'],
                $cnfAdmin['clave'],
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                 PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                 PDO::ATTR_EMULATE_PREPARES => false]
            );
            $pdo->exec("SET time_zone = '-04:00'");

            $repo = new RepositorioAdmin($pdo);
            $admin = $repo->credencialesAdmin($correo);

            $valido = $admin !== null
                && (int)$admin['activo'] === 1
                && password_verify($clave, (string)$admin['hash_contrasena_admin']);

            if ($valido) {
                SesionAdmin::autenticar(
                    (int)$admin['id_admin'],
                    (string)$admin['nombre'],
                    (string)$admin['correo']
                );

                try {
                    $repo->registrarAcceso((int)$admin['id_admin']);
                    $repo->registrarAccion(
                        (int)$admin['id_admin'],
                        'LOGIN',
                        'ADMINISTRADOR',
                        (int)$admin['id_admin'],
                        'OK',
                        'Acceso desde ' . ($_SERVER['REMOTE_ADDR'] ?? 'desconocido')
                    );
                } catch (Throwable $e) {
                    error_log('[KIRO][ADMIN] Error en bitácora: ' . $e->getMessage());
                }

                header('Location: index.php', true, 303);
                exit;
            } else {
                error_log('[KIRO][ADMIN] Intento fallido desde ' . ($_SERVER['REMOTE_ADDR'] ?? 'desconocido'));
                $errores[] = 'Credenciales incorrectas o cuenta inactiva.';
            }
        } catch (Throwable $e) {
            error_log('[KIRO][ADMIN] ' . $e->getMessage());
            $errores[] = 'No se pudo procesar el acceso en este momento.';
        }
    }
}

require $raiz . '/app/views/admin/login.php';
