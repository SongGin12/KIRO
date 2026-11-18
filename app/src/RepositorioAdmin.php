<?php
/**
 * KIRO - Repositorio de datos administrativos
 * ---------------------------------------------------------------
 * Usa la conexión kiro_admin, que tiene acceso restringido:
 *   - SELECT usuario (nombre, correo, fecha_registro, id_usuario) — sin hash
 *   - SELECT/UPDATE administrador (incluyendo hash para verificar login)
 *   - INSERT accion_admin (bitácora)
 *   - EXECUTE sp_emitir_codigo_activacion
 *
 * NO puede leer: nota, recuerdo, cita, proyecto, actividad, recurso,
 * categoría, historial_accion, perfil_kiro, registro_usuario.
 */

declare(strict_types=1);

final class RepositorioAdmin
{
    public function __construct(private PDO $pdo)
    {
    }

    // ─── Autenticación del administrador ──────────────────────────

    /**
     * Busca un administrador activo por correo.
     * Devuelve id, nombre, correo y hash para verificar con password_verify.
     */
    public function credencialesAdmin(string $correo): ?array
    {
        $st = $this->pdo->prepare(
            'SELECT id_admin, nombre, correo, hash_contrasena_admin, activo
               FROM ADMINISTRADOR
              WHERE correo = :correo
              LIMIT 1'
        );
        $st->execute([':correo' => $correo]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    /** Registra la fecha del último acceso. */
    public function registrarAcceso(int $idAdmin): void
    {
        $st = $this->pdo->prepare(
            'UPDATE ADMINISTRADOR SET ultimo_acceso = NOW() WHERE id_admin = :id'
        );
        $st->execute([':id' => $idAdmin]);
    }

    // ─── Consultas de usuarios ────────────────────────────────────

    /**
     * Lista de usuarios con datos públicos (sin hash ni datos privados).
     * kiro_admin solo puede leer: id_usuario, nombre, correo, fecha_registro.
     * El estado de activación se obtiene en una consulta separada que usa root
     * en tools/, pero aquí lo omitimos — el SP nos dirá si ya está activo.
     */
    public function listaUsuarios(): array
    {
        $st = $this->pdo->query(
            'SELECT id_usuario, nombre, correo, fecha_registro
               FROM USUARIO
              ORDER BY id_usuario'
        );

        return $st->fetchAll();
    }

    /**
     * Datos mínimos de un usuario específico (sin hash).
     */
    public function usuario(int $idUsuario): ?array
    {
        $st = $this->pdo->prepare(
            'SELECT id_usuario, nombre, correo, fecha_registro
               FROM USUARIO
              WHERE id_usuario = :id
              LIMIT 1'
        );
        $st->execute([':id' => $idUsuario]);
        $fila = $st->fetch();

        return $fila ?: null;
    }

    // ─── Activación controlada ────────────────────────────────────

    /**
     * Emite un código de activación para un usuario.
     * Solo funciona para usuarios 1 y 2 (restricción del SP).
     *
     * El SP requiere:
     *   IN p_id_usuario, p_id_admin, p_hash_codigo (SHA-256 hex del código), p_vigencia_minutos
     *   OUT p_id_codigo, p_expira_en, p_resultado
     *
     * Esta función genera un código aleatorio, calcula su SHA-256 y lo pasa al SP.
     * Devuelve ['resultado' => string, 'codigo' => string (código en claro, si OK)].
     *
     * @return array{resultado:string, codigo:string}
     */
    public function emitirCodigoActivacion(int $idUsuario, int $idAdmin, int $vigenciaMin = 30): array
    {
        // Generar código aleatorio de 32 bytes (64 hex chars)
        $codigoClaro = bin2hex(random_bytes(32));
        $hashCodigo  = hash('sha256', $codigoClaro);

        try {
            $st = $this->pdo->prepare(
                'CALL sp_emitir_codigo_activacion(:usuario, :admin, :hash_codigo, :vigencia, @id_codigo, @expira_en, @resultado)'
            );
            $st->execute([
                ':usuario'     => $idUsuario,
                ':admin'       => $idAdmin,
                ':hash_codigo' => $hashCodigo,
                ':vigencia'    => $vigenciaMin,
            ]);

            $out = $this->pdo->query(
                'SELECT @id_codigo AS id_codigo, @expira_en AS expira_en, @resultado AS resultado'
            )->fetch();

            $resultado = (string) ($out['resultado'] ?? 'ERROR_INTERNO');

            return [
                'resultado' => $resultado,
                'codigo'    => $resultado === 'OK' ? $codigoClaro : '',
            ];
        } catch (\Throwable $e) {
            error_log('[KIRO][ADMIN] Error al emitir código: ' . $e->getMessage());
            return ['resultado' => 'ERROR_INTERNO', 'codigo' => ''];
        }
    }

    // ─── Bitácora ─────────────────────────────────────────────────

    /** Registra una acción administrativa. */
    public function registrarAccion(
        int    $idAdmin,
        string $tipo,
        string $entidad,
        ?int   $idObjetivo,
        string $resultado,
        string $detalle = ''
    ): void {
        $st = $this->pdo->prepare(
            'INSERT INTO ACCION_ADMIN
                (id_admin, fecha, tipo_accion, entidad, id_objetivo, resultado, detalle)
             VALUES (:admin, NOW(6), :tipo, :entidad, :objetivo, :resultado, :detalle)'
        );
        $st->execute([
            ':admin'     => $idAdmin,
            ':tipo'      => $tipo,
            ':entidad'   => $entidad,
            ':objetivo'  => $idObjetivo,
            ':resultado' => $resultado,
            ':detalle'   => mb_substr($detalle, 0, 255),
        ]);
    }

    /** Últimas acciones administrativas (para el panel). */
    public function ultimasAcciones(int $limite = 15): array
    {
        $st = $this->pdo->prepare(
            'SELECT a.id_accion_admin, a.fecha, a.tipo_accion, a.entidad,
                    a.id_objetivo, a.resultado, a.detalle,
                    adm.nombre AS admin_nombre
               FROM ACCION_ADMIN a
               LEFT JOIN ADMINISTRADOR adm ON adm.id_admin = a.id_admin
              ORDER BY a.fecha DESC
              LIMIT :limite'
        );
        $st->bindValue(':limite', $limite, PDO::PARAM_INT);
        $st->execute();

        return $st->fetchAll();
    }
}
