<?php
/**
 * KIRO - Sesión administrativa (separada de la sesión de usuario)
 * ---------------------------------------------------------------
 * Nombre de sesión distinto: KIRO_ADMIN_SESION
 * No interfiere con la sesión de usuario regular.
 */

declare(strict_types=1);

final class SesionAdmin
{
    private const NOMBRE          = 'KIRO_ADMIN_SESION';
    private const MAX_INACTIVIDAD = 1200; // 20 minutos

    private function __construct() {}

    public static function iniciar(): void
    {
        if (session_status() === PHP_SESSION_ACTIVE) {
            return;
        }

        $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';

        session_name(self::NOMBRE);
        session_set_cookie_params([
            'lifetime' => 0,
            'path'     => '/admin/',
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
        return isset($_SESSION['id_admin']) && (int) $_SESSION['id_admin'] > 0;
    }

    public static function adminId(): ?int
    {
        return self::autenticado() ? (int) $_SESSION['id_admin'] : null;
    }

    public static function nombre(): string
    {
        return (string) ($_SESSION['admin_nombre'] ?? '');
    }

    public static function autenticar(int $idAdmin, string $nombre, string $correo): void
    {
        session_regenerate_id(true);
        $_SESSION['id_admin']         = $idAdmin;
        $_SESSION['admin_nombre']     = $nombre;
        $_SESSION['admin_correo']     = $correo;
        $_SESSION['iniciada_en']      = time();
        $_SESSION['ultima_actividad'] = time();
        $_SESSION['csrf']             = bin2hex(random_bytes(32));
    }

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

    public static function exigirAdmin(): void
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
