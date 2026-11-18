<?php
/**
 * KIRO - Registro publico (correo + contrasena)
 * ---------------------------------------------------------------
 * Crea USUARIO + PERFIL_KIRO + REGISTRO_USUARIO en una transaccion.
 * No inicia sesion automaticamente: el usuario entra desde login.php.
 */

declare(strict_types=1);

$config = require dirname(__DIR__) . '/app/bootstrap.php';

if (Sesion::autenticado()) {
    header('Location: index.php', true, 303);
    exit;
}

$errores = [];
$nombre  = '';
$correo  = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nombre  = trim((string) ($_POST['nombre'] ?? ''));
    $correo  = mb_strtolower(trim((string) ($_POST['correo'] ?? '')), 'UTF-8');
    $clave   = (string) ($_POST['clave'] ?? '');
    $clave2  = (string) ($_POST['clave2'] ?? '');

    if (!Sesion::csrfValido($_POST['csrf'] ?? null)) {
        $errores[] = 'El formulario venció. Vuelve a intentarlo.';
    }
    if (mb_strlen($nombre) < 2 || mb_strlen($nombre) > 100) {
        $errores[] = 'El nombre debe tener entre 2 y 100 caracteres.';
    }
    if ($correo === '' || !filter_var($correo, FILTER_VALIDATE_EMAIL) || mb_strlen($correo) > 150) {
        $errores[] = 'Escribe un correo electrónico válido.';
    }
    if (mb_strlen($clave) < 8) {
        $errores[] = 'La contraseña debe tener al menos 8 caracteres.';
    } elseif (strlen($clave) > 72) {
        // bcrypt solo usa los primeros 72 bytes: se rechaza en vez de
        // aceptar una contrasena que en la practica quedaria truncada.
        $errores[] = 'La contraseña no puede superar los 72 caracteres.';
    }
    if ($clave !== $clave2) {
        $errores[] = 'Las contraseñas no coinciden.';
    }

    if ($errores === []) {
        try {
            $repo = new RepositorioAutenticacion(
                Database::conectar($config['db'], 'app'),
                Database::conectar($config['auth'], 'auth')
            );

            if ($repo->existeCorreo($correo)) {
                $errores[] = 'Ya existe una cuenta con ese correo electrónico.';
            } else {
                $hash = password_hash($clave, PASSWORD_BCRYPT, ['cost' => 12]);
                $repo->registrar($nombre, $correo, $hash);

                header(
                    'Location: login.php?registro=1&correo=' . rawurlencode($correo),
                    true,
                    303
                );
                exit;
            }
        } catch (PDOException $e) {
            error_log('[KIRO][REGISTRO] ' . $e->getMessage());

            if ($e->getCode() === '23000') {
                $errores[] = 'Ya existe una cuenta con ese correo electrónico.';
            } else {
                $errores[] = 'No se pudo crear la cuenta en este momento.';
            }
        } catch (Throwable $e) {
            error_log('[KIRO][REGISTRO] ' . $e->getMessage());
            $errores[] = 'No se pudo crear la cuenta en este momento.';
        }
    }
}

require KIRO_APP . '/views/registro.php';
