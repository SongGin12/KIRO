<?php
/**
 * KIRO - Cierre de sesión
 * ---------------------------------------------------------------
 * Solo por POST y con token CSRF: un enlace GET no debe cerrar sesiones.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php', true, 303);
    exit;
}

if (!Sesion::csrfValido($_POST['csrf'] ?? null)) {
    http_response_code(400);
    $mensaje = 'La solicitud de cierre de sesión no es válida.';
    require KIRO_APP . '/views/error.php';
    exit;
}

$idUsuario = Sesion::usuarioId();
$idSesion  = isset($_SESSION['id_sesion_log']) ? (int) $_SESSION['id_sesion_log'] : null;

if ($idUsuario !== null) {
    try {
        $repo = new RepositorioAutenticacion(
            Database::conectar($config['db'], 'app'),
            Database::conectar($config['auth'], 'auth')
        );
        $repo->cerrarSesion($idSesion, $idUsuario);
    } catch (Throwable $e) {
        error_log('[KIRO][LOGOUT] ' . $e->getMessage());
    }
}

Sesion::cerrar();

header('Location: login.php?salida=1', true, 303);
exit;
