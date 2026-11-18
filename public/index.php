<?php
/**
 * KIRO - Pagina Inicio
 * ---------------------------------------------------------------
 * Flujo de la peticion:
 *   1. bootstrap.php  -> configuracion, zona horaria, sesion, clases
 *   2. exigirLogin    -> sin sesion no se consulta ningun dato
 *   3. Database       -> conexion PDO con la cuenta kiro_app
 *   4. Repositorio    -> consultas preparadas con $_SESSION['id_usuario']
 *   5. Vista inicio.php -> solo HTML con los datos ya preparados
 *
 * La vista no contiene SQL.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

Sesion::exigirLogin();
$idUsuario = (int) Sesion::usuarioId();

$titulo       = 'Inicio';
$paginaActiva = 'inicio';

try {
    $pdo   = Database::conectar($config['db'], 'app');
    $repo  = new RepositorioInicio($pdo);
    $datos = $repo->panelInicio($idUsuario);
} catch (Throwable $e) {
    $mensaje = $e instanceof RuntimeException
        ? $e->getMessage()
        : 'No se pudieron cargar los datos de Inicio.';
    require KIRO_APP . '/views/error.php';
    exit;
}

// Si la cuenta desaparecio, la sesion ya no es valida.
if (($datos['usuario'] ?? null) === null) {
    Sesion::cerrar();
    header('Location: login.php', true, 303);
    exit;
}

ob_start();
require KIRO_APP . '/views/inicio.php';
$contenido = ob_get_clean();

require KIRO_APP . '/views/layout.php';
