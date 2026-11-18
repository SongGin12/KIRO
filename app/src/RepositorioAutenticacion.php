<?php
/**
 * KIRO - Acceso a datos de autenticacion
 * ---------------------------------------------------------------
 * Usa DOS conexiones con privilegios distintos:
 *   $app  (kiro_app)  : registro, perfiles, bitacora de sesiones.
 *   $auth (kiro_auth) : SOLO lectura de id_usuario/correo/hash.
 *
 * Ninguna de las dos puede leer tablas privadas (NOTA, CITA, ...).
 * No se guarda ninguna contrasena en claro.
 */

declare(strict_types=1);

final class RepositorioAutenticacion
{
    public function __construct(private PDO $app, private PDO $auth)
    {
    }

    /**
     * Credenciales para verificar el inicio de sesion.
     *
     * @return array{id_usuario:int,correo:string,hash_contrasena:string}|null
     */
    public function credenciales(string $correo): ?array
    {
        $sql = 'SELECT id_usuario, correo, hash_contrasena
                  FROM USUARIO
                 WHERE correo = :correo
                 LIMIT 1';
        $st = $this->auth->prepare($sql);
        $st->execute([':correo' => $correo]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    public function existeCorreo(string $correo): bool
    {
        $st = $this->app->prepare('SELECT 1 FROM USUARIO WHERE correo = :correo LIMIT 1');
        $st->execute([':correo' => $correo]);

        return $st->fetchColumn() !== false;
    }

    /**
     * Crea usuario + perfil inicial + registro de procedencia.
     * Todo en una transaccion: o quedan las tres filas o ninguna.
     *
     * @return int id_usuario nuevo
     */
    public function registrar(string $nombre, string $correo, string $hash): int
    {
        $this->app->beginTransaction();

        try {
            $st = $this->app->prepare(
                'INSERT INTO USUARIO (nombre, correo, fecha_registro, hash_contrasena)
                 VALUES (:nombre, :correo, NOW(), :hash)'
            );
            $st->execute([
                ':nombre' => $nombre,
                ':correo' => $correo,
                ':hash'   => $hash,
            ]);
            $idUsuario = (int) $this->app->lastInsertId();

            $st = $this->app->prepare(
                'INSERT INTO PERFIL_KIRO
                    (nombre_companero, personalidad, estilo_comunicacion,
                     color_principal, memoria_activa, id_usuario)
                 VALUES (:companero, :personalidad, :estilo, :color, 1, :id)'
            );
            $st->execute([
                ':companero'    => 'Kiro',
                ':personalidad' => 'Amigable',
                ':estilo'       => 'Cercano',
                ':color'        => 'Azul',
                ':id'           => $idUsuario,
            ]);

            $st = $this->app->prepare(
                'INSERT INTO REGISTRO_USUARIO
                    (metodo_registro, estado_verificacion, fecha_verificacion, id_usuario)
                 VALUES (:metodo, :estado, NULL, :id)'
            );
            $st->execute([
                ':metodo' => 'Correo electrónico',
                ':estado' => 'Pendiente',
                ':id'     => $idUsuario,
            ]);

            $this->app->commit();

            return $idUsuario;
        } catch (Throwable $e) {
            if ($this->app->inTransaction()) {
                $this->app->rollBack();
            }
            throw $e;
        }
    }

    /** Fila minima del usuario en sesion (sin hash). */
    public function usuario(int $idUsuario): ?array
    {
        $st = $this->app->prepare(
            'SELECT id_usuario, nombre, correo, fecha_registro
               FROM USUARIO
              WHERE id_usuario = :id
              LIMIT 1'
        );
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /** Abre una fila de bitacora de sesion y devuelve su id. */
    public function abrirSesion(int $idUsuario): int
    {
        $st = $this->app->prepare(
            "INSERT INTO INICIO_SESION (fecha_inicio, fecha_fin, estado_sesion, id_usuario)
             VALUES (NOW(), NULL, 'Activa', :id)"
        );
        $st->execute([':id' => $idUsuario]);

        return (int) $this->app->lastInsertId();
    }

    /** Cierra la fila de bitacora del cierre de sesion. */
    public function cerrarSesion(?int $idSesion, int $idUsuario): void
    {
        if ($idSesion === null || $idSesion <= 0) {
            return;
        }

        $st = $this->app->prepare(
            "UPDATE INICIO_SESION
                SET fecha_fin = NOW(), estado_sesion = 'Cerrada'
              WHERE id_sesion = :sesion AND id_usuario = :usuario"
        );
        $st->execute([':sesion' => $idSesion, ':usuario' => $idUsuario]);
    }
}
