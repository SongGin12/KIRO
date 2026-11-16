<?php
/**
 * KIRO - Conexion a MariaDB mediante PDO
 * ---------------------------------------------------------------
 * Una sola clase, una sola conexion por peticion.
 *
 * - Los datos de conexion llegan desde app/config/config.php.
 * - Los errores tecnicos se registran en storage/logs/error.log.
 * - Al navegador solo le llega un mensaje generico.
 * - La zona horaria de la sesion SQL se fija en -04:00 para que
 *   NOW() coincida con America/La_Paz (Bolivia no usa horario de verano).
 */

declare(strict_types=1);

final class Database
{
    private static ?PDO $conexion = null;

    /** Impide crear instancias: se usa siempre Database::conectar(). */
    private function __construct()
    {
    }

    /**
     * @param array{host:string,puerto:int,nombre:string,usuario:string,clave:string,charset:string} $config
     */
    public static function conectar(array $config): PDO
    {
        if (self::$conexion instanceof PDO) {
            return self::$conexion;
        }

        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            $config['host'],
            (int) $config['puerto'],
            $config['nombre'],
            $config['charset']
        );

        try {
            $pdo = new PDO($dsn, $config['usuario'], $config['clave'], [
                // Errores como excepciones: nunca se muestran detalles al usuario.
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                // Sin emulacion: las consultas preparadas son reales en el servidor.
                PDO::ATTR_EMULATE_PREPARES   => false,
                // Los resultados llegan como arreglos asociativos.
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                // Sin conexiones persistentes: mas simple y predecible.
                PDO::ATTR_PERSISTENT         => false,
            ]);

            // Bolivia = UTC-4 todo el ano. Se usa el desfase y no el nombre
            // de la zona para no depender de las tablas de zonas horarias.
            $pdo->exec("SET time_zone = '-04:00'");
        } catch (PDOException $e) {
            // El detalle va al log (incluye host y usuario, nunca la clave).
            error_log('[KIRO][PDO] ' . $e->getMessage());

            // Al navegador: mensaje generico.
            throw new RuntimeException(
                'No se pudo conectar con la base de datos de KIRO.'
            );
        }

        self::$conexion = $pdo;

        return self::$conexion;
    }
}
