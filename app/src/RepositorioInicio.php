<?php
/**
 * KIRO - Consultas de la pagina Inicio
 * ---------------------------------------------------------------
 * Este es el UNICO archivo con SQL de la etapa 1.
 *
 * Todas las consultas:
 *   - usan columnas que existen en database/KIRO_MariaDB.sql;
 *   - filtran por id_usuario, tomado de la configuracion (aun no hay login);
 *   - son consultas preparadas con parametros vinculados;
 *   - solo leen datos: no insertan, actualizan ni eliminan nada.
 */

declare(strict_types=1);

final class RepositorioInicio
{
    public function __construct(private PDO $pdo)
    {
    }

    /**
     * Reune en un solo arreglo todo lo que la vista necesita.
     *
     * @return array<string, mixed>
     */
    public function panelInicio(int $idUsuario): array
    {
        return [
            'usuario'          => $this->usuario($idUsuario),
            'perfil'           => $this->perfil($idUsuario),
            'proximaCita'      => $this->proximaCita($idUsuario),
            'ultimaCita'       => $this->ultimaCita($idUsuario),
            'resumenActividad' => $this->resumenActividades($idUsuario),
            'actividades'      => $this->actividadesProximas($idUsuario, 3),
            'proyectos'        => $this->proyectosActivos($idUsuario, 3),
        ];
    }

    /** Nombre real del usuario que se muestra en el saludo. */
    public function usuario(int $idUsuario): ?array
    {
        $sql = 'SELECT id_usuario, nombre, correo, fecha_registro
                  FROM USUARIO
                 WHERE id_usuario = :id
                 LIMIT 1';

        $st = $this->pdo->prepare($sql);
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /** Perfil del compañero: personalidad, estilo y color principal. */
    public function perfil(int $idUsuario): ?array
    {
        $sql = 'SELECT nombre_companero, personalidad, estilo_comunicacion,
                       color_principal, memoria_activa
                  FROM PERFIL_KIRO
                 WHERE id_usuario = :id
                 LIMIT 1';

        $st = $this->pdo->prepare($sql);
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /**
     * Próxima cita futura.
     * NOW() usa la zona horaria de la sesion (-04:00, fijada en Database).
     */
    public function proximaCita(int $idUsuario): ?array
    {
        $sql = "SELECT id_cita, titulo, fecha_inicio, duracion_minutos,
                       lugar, estado
                  FROM CITA
                 WHERE id_usuario = :id
                   AND estado <> 'Cancelada'
                   AND fecha_inicio >= NOW()
                 ORDER BY fecha_inicio ASC
                 LIMIT 1";

        $st = $this->pdo->prepare($sql);
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /**
     * Ultima cita pasada. Se usa solo cuando no hay proximas citas,
     * para mostrar contexto real en lugar de dejar la tarjeta vacia.
     */
    public function ultimaCita(int $idUsuario): ?array
    {
        $sql = "SELECT id_cita, titulo, fecha_inicio, duracion_minutos,
                       lugar, estado
                  FROM CITA
                 WHERE id_usuario = :id
                   AND estado <> 'Cancelada'
                   AND fecha_inicio < NOW()
                 ORDER BY fecha_inicio DESC
                 LIMIT 1";

        $st = $this->pdo->prepare($sql);
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /**
     * Actividades que no estan terminadas.
     *
     * Nota academica: los datos usan 'Completada' para ACTIVIDAD y
     * 'Completado' para PROYECTO. Mientras no se aprueben los dominios
     * (seccion 7.2 del plan) se filtra por lista blanca provisional.
     */
    public function resumenActividades(int $idUsuario): array
    {
        $sql = "SELECT COUNT(*)              AS total,
                       MIN(fecha_limite)    AS proxima,
                       SUM(prioridad = 'Alta') AS prioritarias
                  FROM ACTIVIDAD
                 WHERE id_usuario = :id
                   AND estado IN ('Pendiente', 'En progreso')";

        $st = $this->pdo->prepare($sql);
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return [
            'total'        => (int) ($fila['total'] ?? 0),
            'proxima'      => $fila['proxima'] ?? null,
            'prioritarias' => (int) ($fila['prioritarias'] ?? 0),
        ];
    }

    /** Lista corta de actividades pendientes, ordenadas por fecha limite. */
    public function actividadesProximas(int $idUsuario, int $limite = 3): array
    {
        $sql = "SELECT id_actividad, titulo, fecha_limite, prioridad, estado, id_proyecto
                  FROM ACTIVIDAD
                 WHERE id_usuario = :id
                   AND estado IN ('Pendiente', 'En progreso')
                 ORDER BY fecha_limite ASC
                 LIMIT :limite";

        $st = $this->pdo->prepare($sql);
        $st->bindValue(':id', $idUsuario, PDO::PARAM_INT);
        $st->bindValue(':limite', $limite, PDO::PARAM_INT);
        $st->execute();

        return $st->fetchAll();
    }

    /** Proyectos en curso del usuario. */
    public function proyectosActivos(int $idUsuario, int $limite = 3): array
    {
        $sql = "SELECT id_proyecto, nombre, estado, prioridad, fecha_fin
                  FROM PROYECTO
                 WHERE id_usuario = :id
                   AND estado = 'En progreso'
                 ORDER BY fecha_fin ASC
                 LIMIT :limite";

        $st = $this->pdo->prepare($sql);
        $st->bindValue(':id', $idUsuario, PDO::PARAM_INT);
        $st->bindValue(':limite', $limite, PDO::PARAM_INT);
        $st->execute();

        return $st->fetchAll();
    }
}
