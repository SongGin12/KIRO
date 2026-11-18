<?php
/**
 * KIRO - Configuración de ejemplo
 * ---------------------------------------------------------------
 * Copia este archivo como config.php y ajusta los valores de tu
 * entorno local. config.php NO se versiona (esta en .gitignore).
 *
 * Este archivo de ejemplo si se versiona, para que cualquiera pueda
 * saber que claves de configuracion existen sin ver credenciales.
 *
 * DOS CONEXIONES, DOS ROLES
 *   db    -> kiro_app : paginas, registro, perfiles, bitacora de sesiones.
 *   auth  -> kiro_auth: solo lectura de id_usuario/correo/hash_contrasena.
 *   Ninguna de las dos puede leer las tablas privadas (NOTA, CITA, ...).
 */

declare(strict_types=1);

return [
    'app' => [
        'nombre' => 'KIRO',

        // Zona horaria de Bolivia. No se aplica DST.
        'zona_horaria' => 'America/La_Paz',
    ],

    'db' => [
        'host'    => '127.0.0.1',
        'puerto'  => 3306,
        'nombre'  => 'Kiro',
        'usuario' => 'kiro_app',
        'clave'   => 'CAMBIAR_CLAVE_APP',
        'charset' => 'utf8mb4',
    ],

    'auth' => [
        'host'    => '127.0.0.1',
        'puerto'  => 3306,
        'nombre'  => 'Kiro',
        'usuario' => 'kiro_auth',
        'clave'   => 'CAMBIAR_CLAVE_AUTH',
        'charset' => 'utf8mb4',
    ],
];
