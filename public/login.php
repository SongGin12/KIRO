<?php
/**
 * KIRO - Inicio de sesión
 * ---------------------------------------------------------------
 * Flujo: bootstrap -> validar CSRF -> verificar con password_verify
 * -> regenerar ID de sesión -> redirigir a Inicio.
 *
 * Mensajes deliberadamente genéricos: no se revela si el correo existe.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

if (Sesion::autenticado()) {
    header('Location: index.php', true, 303);
    exit;
}

$errores      = [];
$correo       = '';
$mensajeExito = null;

if (($_GET['registro'] ?? '') === '1') {
    $mensajeExito = 'Tu cuenta se creó correctamente. Ya puedes iniciar sesión.';
    $correo = mb_strtolower(trim((string) ($_GET['correo'] ?? '')), 'UTF-8');
} elseif (($_GET['salida'] ?? '') === '1') {
    $mensajeExito = 'Cerraste sesión correctamente.';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $correo = mb_strtolower(trim((string) ($_POST['correo'] ?? '')), 'UTF-8');
    $clave  = (string) ($_POST['clave'] ?? '');

    if (!Sesion::csrfValido($_POST['csrf'] ?? null)) {
        $errores[] = 'El formulario venció. Vuelve a intentarlo.';
    }
    if ($correo === '' || !filter_var($correo, FILTER_VALIDATE_EMAIL)) {
        $errores[] = 'Escribe un correo electrónico válido.';
    }
    if ($clave === '') {
        $errores[] = 'Escribe tu contraseña.';
    }

    if ($errores === []) {
        try {
            $repo = new RepositorioAutenticacion(
                Database::conectar($config['db'], 'app'),
                Database::conectar($config['auth'], 'auth')
            );

            $credencial = $repo->credenciales($correo);
            $valida = $credencial !== null
                && password_verify($clave, (string) $credencial['hash_contrasena']);

            if ($valida) {
                $usuario = $repo->usuario((int) $credencial['id_usuario']);

                if ($usuario === null) {
                    $errores[] = 'La cuenta no está disponible en este momento.';
                } else {
                    Sesion::autenticar(
                        (int) $usuario['id_usuario'],
                        (string) $usuario['nombre'],
                        (string) $usuario['correo']
                    );

                    // La bitacora no debe impedir el acceso si fallara.
                    try {
                        $_SESSION['id_sesion_log'] = $repo->abrirSesion((int) $usuario['id_usuario']);
                    } catch (Throwable $e) {
                        error_log('[KIRO][LOGIN] No se pudo registrar la sesion: ' . $e->getMessage());
                    }

                    header('Location: index.php', true, 303);
                    exit;
                }
            } else {
                // Sin correo ni contrasena en el registro: solo el intento.
                error_log('[KIRO][LOGIN] Intento fallido desde ' . ($_SERVER['REMOTE_ADDR'] ?? 'desconocido'));
                $errores[] = 'Correo o contraseña incorrectos.';
            }
        } catch (Throwable $e) {
            error_log('[KIRO][LOGIN] ' . $e->getMessage());
            $errores[] = 'No se pudo iniciar sesión en este momento. Inténtalo de nuevo.';
        }
    }
}

require KIRO_APP . '/views/login.php';
