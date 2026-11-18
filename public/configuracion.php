<?php
/**
 * KIRO - Pagina Configuración
 * Reutiliza el mismo flujo que Inicio; solo cambia la vista.
 * El usuario sale SIEMPRE de la sesion, nunca de un id fijo.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

Sesion::exigirLogin();
$idUsuario = (int) Sesion::usuarioId();

$titulo       = 'Configuración';
$paginaActiva = 'ajustes';

try {
    $pdo  = Database::conectar($config['db'], 'app');
    $repo = new RepositorioInicio($pdo);
    $datos = [
        'usuario' => $repo->usuario($idUsuario),
        'perfil'  => $repo->perfil($idUsuario),
    ];
} catch (Throwable $e) {
    $mensaje = $e instanceof RuntimeException
        ? $e->getMessage()
        : 'No se pudieron cargar los datos de configuración.';
    require KIRO_APP . '/views/error.php';
    exit;
}

if ($datos['usuario'] === null) {
    Sesion::cerrar();
    header('Location: login.php', true, 303);
    exit;
}

ob_start();
require KIRO_APP . '/views/configuracion.php';
$contenido = ob_get_clean();

require KIRO_APP . '/views/layout.php';
