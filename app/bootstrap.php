<?php
/**
 * KIRO - Arranque comun de la aplicación
 * ---------------------------------------------------------------
 * Todo pasa por aquí: zona horaria, manejo de errores, carga de
 * funciones auxiliares y de las clases del proyecto.
 *
 * Devuelve el arreglo de configuracion para que cada pagina lo use.
 */

declare(strict_types=1);

define('KIRO_RAIZ', dirname(__DIR__));
define('KIRO_APP', __DIR__);

// 1. Funciones de apoyo (se necesitan incluso para la pagina de error)
require KIRO_APP . '/src/helpers.php';

// 2. Clases del proyecto (carga explicita y visible)
require KIRO_APP . '/src/Database.php';
require KIRO_APP . '/src/Sesion.php';
require KIRO_APP . '/src/RepositorioInicio.php';
require KIRO_APP . '/src/RepositorioAutenticacion.php';

// 3. Configuración (config.php no esta en Git)
$rutaConfig = KIRO_APP . '/config/config.php';
if (!is_file($rutaConfig)) {
    $mensaje = 'Falta el archivo app/config/config.php. Copia config.example.php, renombralo y ajusta los datos de conexion.';
    require KIRO_APP . '/views/error.php';
    exit;
}
$config = require $rutaConfig;

// 4. Zona horaria de Bolivia (sin horario de verano, UTC-4)
date_default_timezone_set($config['app']['zona_horaria'] ?? 'America/La_Paz');

// 5. Errores: nunca al navegador, siempre al archivo de registro
error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');

$directorioLogs = KIRO_RAIZ . '/storage/logs';
if (!is_dir($directorioLogs)) {
    @mkdir($directorioLogs, 0775, true);
}
ini_set('error_log', $directorioLogs . '/error.log');

// 6. Texto en UTF-8
mb_internal_encoding('UTF-8');

// 7. Sesion segura (cookie HttpOnly, SameSite, modo estricto, CSRF).
Sesion::iniciar();

return $config;
