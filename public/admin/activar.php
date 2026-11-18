<?php
/**
 * KIRO Admin - Activación controlada (emisión de código)
 * Solo para usuarios 1 y 2.
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

$titulo       = 'Activación';
$paginaActiva = 'activar';

$errores           = [];
$mensaje           = null;
$codigoEmitido     = null;
$idUsuarioActivado = null;

const IDS_ACTIVABLES = [1, 2];

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

    // Solo mostramos los usuarios activables (1 y 2)
    $todosUsuarios = $repo->listaUsuarios();
    $usuariosActivables = array_values(array_filter(
        $todosUsuarios,
        fn($u) => in_array((int)$u['id_usuario'], IDS_ACTIVABLES, true)
    ));

    // Detectar si ya están activados usando kiro_auth
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
              WHERE id_usuario IN (1, 2)
                AND (hash_contrasena LIKE '\$2y\$%'
                  OR hash_contrasena LIKE '\$2a\$%'
                  OR hash_contrasena LIKE '\$2b\$%'
                  OR hash_contrasena LIKE '\$argon2%')"
        );
        $idsActivos = array_map('intval', $stA->fetchAll(PDO::FETCH_COLUMN));
    } catch (Throwable $e) {
        error_log('[KIRO][ADMIN] Error al chequear idsActivos con auth: ' . $e->getMessage());
    }

    foreach ($usuariosActivables as &$u) {
        $u['ya_activo'] = in_array((int)$u['id_usuario'], $idsActivos, true);
    }
    unset($u);

    // Procesar formulario de emisión
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'emitir') {

        if (!SesionAdmin::csrfValido($_POST['csrf'] ?? null)) {
            $errores[] = 'Formulario inválido. Vuelve a intentarlo.';
        }

        $idUsuario = (int)($_POST['id_usuario'] ?? 0);

        if ($errores === []) {
            if (!in_array($idUsuario, IDS_ACTIVABLES, true)) {
                $errores[] = 'Solo se puede activar a los usuarios 1 y 2.';
            }
        }

        if ($errores === []) {
            $idAdmin = (int)SesionAdmin::adminId();

            $usuarioTarget = $repo->usuario($idUsuario);
            if ($usuarioTarget === null) {
                $errores[] = 'Usuario no encontrado.';
            } else {
                try {
                    $salida    = $repo->emitirCodigoActivacion($idUsuario, $idAdmin, 30);
                    $resultado = $salida['resultado'];
                    $codigoHex = $salida['codigo'];

                    if ($resultado === 'OK' && $codigoHex !== '') {
                        $codigoEmitido     = $codigoHex;
                        $idUsuarioActivado = $idUsuario;
                        $mensaje = "Código emitido correctamente para el usuario #{$idUsuario} "
                                 . "({$usuarioTarget['nombre']}). Vigencia: 30 minutos.";
                        try {
                            $repo->registrarAccion(
                                $idAdmin, 'EMITIR_CODIGO_WEB', 'USUARIO',
                                $idUsuario, 'OK',
                                "Panel web; usuario #{$idUsuario} {$usuarioTarget['correo']}"
                            );
                        } catch (Throwable) {}
                    } elseif ($resultado === 'CUENTA_YA_ACTIVADA') {
                        $errores[] = "El usuario #{$idUsuario} ya tiene una contraseña activa. No es necesario emitir código.";
                    } elseif ($resultado === 'ADMIN_NO_AUTORIZADO') {
                        $errores[] = "El administrador actual no tiene permiso para esta operación en la base de datos.";
                    } else {
                        $errores[] = "El procedimiento respondió: {$resultado}.";
                    }
                } catch (Throwable $e) {
                    error_log('[KIRO][ADMIN] Error SP emitir: ' . $e->getMessage());
                    $errores[] = 'Error al ejecutar el procedimiento de activación.';
                }
            }
        }
    }

} catch (Throwable $e) {
    error_log('[KIRO][ADMIN] ' . $e->getMessage());
    $errores[]          = 'No se pudo conectar con la base de datos administrativa.';
    $usuariosActivables = [];
}

ob_start();
require $raiz . '/app/views/admin/activar.php';
$contenido = ob_get_clean();

require $raiz . '/app/views/admin/layout.php';
