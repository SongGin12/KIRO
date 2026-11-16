<?php
/**
 * KIRO - Pagina Inicio
 * ---------------------------------------------------------------
 * Flujo de la peticion:
 *   1. bootstrap.php  -> configuracion, zona horaria, errores, clases
 *   2. Database       -> conexion PDO (una sola por peticion)
 *   3. Repositorio    -> consultas preparadas con id_usuario
 *   4. Vista inicio.php -> solo HTML con los datos ya preparados
 *   5. layout.php     -> estructura comun (menu, encabezado, pie)
 *
 * La vista no contiene SQL: todo el acceso a datos esta en
 * app/src/RepositorioInicio.php.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

$titulo       = 'Inicio';
$paginaActiva = 'inicio';
$idUsuario    = (int) $config['app']['usuario_vista'];

try {
    $pdo   = Database::conectar($config['db']);
    $repo  = new RepositorioInicio($pdo);
    $datos = $repo->panelInicio($idUsuario);
} catch (Throwable $e) {
    // El detalle ya quedo en storage/logs/error.log.
    $mensaje = $e instanceof RuntimeException
        ? $e->getMessage()
        : 'No se pudieron cargar los datos de Inicio.';
    require KIRO_APP . '/views/error.php';
    exit;
}

// El saludo usa el nombre real de la tabla USUARIO. Si el id configurado
// no existe, se avisa y no se inventa ningun nombre.
if (($datos['usuario'] ?? null) === null) {
    $mensaje = 'No se encontro el usuario de vista previa #' . $idUsuario
        . ' en la tabla USUARIO. Revisa la clave usuario_vista en app/config/config.php.';
    require KIRO_APP . '/views/error.php';
    exit;
}

// 4. Se genera el contenido de la vista y despues se envuelve en el layout.
ob_start();
require KIRO_APP . '/views/inicio.php';
$contenido = ob_get_clean();

// 5. Estructura comun
require KIRO_APP . '/views/layout.php';
