<?php
/**
 * KIRO - Pagina Configuración
 * Reutiliza exactamente el mismo flujo que Inicio; solo cambia la vista.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

$titulo       = 'Configuración';
$paginaActiva = 'ajustes';

try {
    $pdo   = Database::conectar($config['db']);
    $repo  = new RepositorioInicio($pdo);
    // Solo se necesitan el usuario y el perfil para mostrar el estado actual.
    $datos = [
        'usuario' => $repo->usuario((int) $config['app']['usuario_vista']),
        'perfil'  => $repo->perfil((int) $config['app']['usuario_vista']),
    ];
} catch (Throwable $e) {
    $mensaje = $e instanceof RuntimeException
        ? $e->getMessage()
        : 'No se pudieron cargar los datos de configuración.';
    require KIRO_APP . '/views/error.php';
    exit;
}

ob_start();
require KIRO_APP . '/views/configuracion.php';
$contenido = ob_get_clean();

require KIRO_APP . '/views/layout.php';
