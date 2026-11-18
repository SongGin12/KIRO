<?php
/**
 * KIRO - Sesiones y proteccion de rutas
 * ---------------------------------------------------------------
 * Centraliza todo lo delicado del ciclo de sesion:
 *   - cookie HttpOnly, SameSite=Lax y Secure cuando hay HTTPS;
 *   - modo estricto (no acepta IDs de sesion inventados);
 *   - regeneracion del ID al iniciar y al cerrar sesion;
 *   - caducidad por inactividad;
 *   - token CSRF por sesion.
 *
 * No contiene SQL.
 */

declare(strict_types=1);

final class Sesion
{
    private const NOMBRE          = 'KIRO_SESION';
    private const MAX_INACTIVIDAD = 1800; // 30 minutos

    private function __construct()
    {
    }

    /** Arranca la sesion una sola vez por peticion. */
    public static function iniciar(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';

        session_name(self::NOMBRE);
        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => '/',
            'domain'   => '',
            'secure'   => $https,
            'httponly' => true,
            'samesite' => 'Lax',
        ]);

        ini_set('session.use_strict_mode', '1');
        ini_set('session.use_only_cookies', '1');
        ini_set('session.gc_maxlifetime', (string) self::MAX_INACTIVIDAD);

        session_start();

        if (isset($_SESSION['ultima_actividad'])
            && time() - (int) $_SESSION['ultima_actividad'] > self::MAX_INACTIVIDAD) {
            // Sesion vencida: se descarta sin conservar datos.
            $_SESSION = [];
            session_regenerate_id(true);
        }

        $_SESSION['ultima_actividad'] = time();

        if (empty($_SESSION['csrf'])) {
            $_SESSION['csrf'] = bin2hex(random_bytes(32));
        }
    }

    public static function autenticado(): bool
    {
        return isset($_SESSION['id_usuario']) && (int) $_SESSION['id_usuario'] > 0;
    }

    public static function usuarioId(): ?int
    {
        return self::autenticado() ? (int) $_SESSION['id_usuario'] : null;
    }

    public static function nombre(): string
    {
        return (string) ($_SESSION['nombre'] ?? '');
    }

    public static function correo(): string
    {
        return (string) ($_SESSION['correo'] ?? '');
    }

    /**
     * Fija la identidad y regenera el ID de sesion.
     * Se llama SOLO despues de verificar la contrasena.
     */
    public static function autenticar(int $idUsuario, string $nombre, string $correo): void
    {
        session_regenerate_id(true);

        $_SESSION['id_usuario']      = $idUsuario;
        $_SESSION['nombre']          = $nombre;
        $_SESSION['correo']          = $correo;
        $_SESSION['iniciada_en']     = time();
        $_SESSION['ultima_actividad'] = time();
        $_SESSION['csrf']            = bin2hex(random_bytes(32));
    }

    /** Destruye la sesion por completo. */
    public static function cerrar(): void
    {
        $_SESSION = [];

        if (ini_get('session.use_cookies')) {
            $p = session_get_cookie_params();
            setcookie(session_name(), '', [
                'expires'  => time() - 42000,
                'path'     => $p['path'],
                'domain'   => $p['domain'],
                'secure'   => $p['secure'],
                'httponly' => true,
                'samesite' => 'Lax',
            ]);
        }

        session_destroy();
    }

    /** Corta la peticion si no hay sesion iniciada. */
    public static function exigirLogin(): void
    {
        if (!self::autenticado()) {
            header('Location: login.php', true, 303);
            exit;
        }
    }

    public static function csrf(): string
    {
        if (empty($_SESSION['csrf'])) {
            $_SESSION['csrf'] = bin2hex(random_bytes(32));
        }

        return (string) $_SESSION['csrf'];
    }

    public static function csrfValido(?string $token): bool
    {
        return is_string($token)
            && $token !== ''
            && !empty($_SESSION['csrf'])
            && hash_equals((string) $_SESSION['csrf'], $token);
    }

    /** Mensaje de una sola lectura para la siguiente pantalla. */
    public static function flash(string $clave, ?string $valor = null): ?string
    {
        if ($valor !== null) {
            $_SESSION['flash'][$clave] = $valor;

            return null;
        }

        $mensaje = $_SESSION['flash'][$clave] ?? null;
        unset($_SESSION['flash'][$clave]);

        return $mensaje === null ? null : (string) $mensaje;
    }
}
