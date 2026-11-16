<?php
/**
 * KIRO - Configuración de ejemplo
 * ---------------------------------------------------------------
 * Copia este archivo como config.php y ajusta los valores de tu
 * entorno local. config.php NO se versiona (esta en .gitignore).
 *
 * Este archivo de ejemplo si se versiona, para que cualquiera pueda
 * saber que claves de configuracion existen sin ver credenciales.
 */

declare(strict_types=1);

return [
    'app' => [
        'nombre' => 'KIRO',

        // Etapa 1: no existe autenticación. La pagina Inicio consulta
        // los datos de este usuario (debe existir en la tabla USUARIO).
        'usuario_vista' => 1,

        // Zona horaria de Bolivia. No se aplica DST.
        'zona_horaria' => 'America/La_Paz',
    ],

    'db' => [
        'host'    => '127.0.0.1',
        'puerto'  => 3306,
        'nombre'  => 'Kiro',
        'usuario' => 'CAMBIAR_USUARIO',
        'clave'   => 'CAMBIAR_CLAVE',
        'charset' => 'utf8mb4',
    ],
];
