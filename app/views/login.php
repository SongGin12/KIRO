<?php
/**
 * KIRO - Vista de inicio de sesión
 * Variables: $errores (array), $correo (string), $mensajeExito (?string)
 */
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>KIRO &middot; Iniciar sesión</title>
  <link rel="stylesheet" href="assets/css/app.css?v=4">
  <link rel="stylesheet" href="assets/css/kiro.css?v=4">
  <link rel="stylesheet" href="assets/css/auth.css?v=1">
</head>
<body class="cuerpo-auth">

  <main class="auth">
    <section class="auth-tarjeta" aria-labelledby="login-titulo">

      <div class="auth-marca">
        <span aria-hidden="true"><?php require_once KIRO_APP . '/views/partials/kiro-gato.php'; kiro_gato('normal', 'gato--mini'); ?></span>
        <span class="auth-marca-texto">
          <span class="auth-marca-nombre">KIRO</span>
          <span class="auth-marca-lema">Tu mundo organizado</span>
        </span>
      </div>

      <h1 id="login-titulo">Iniciar sesión</h1>
      <p class="auth-intro">Entra con el correo y la contraseña de tu cuenta.</p>

      <?php if ($mensajeExito !== null): ?>
        <p class="auth-aviso auth-aviso--ok" role="status"><?= e($mensajeExito) ?></p>
      <?php endif; ?>

      <?php if ($errores !== []): ?>
        <div class="auth-aviso auth-aviso--error" role="alert">
          <ul>
            <?php foreach ($errores as $error): ?>
              <li><?= e($error) ?></li>
            <?php endforeach; ?>
          </ul>
        </div>
      <?php endif; ?>

      <form method="post" action="login.php" novalidate>
        <input type="hidden" name="csrf" value="<?= e(Sesion::csrf()) ?>">

        <div class="auth-campo">
          <label for="correo">Correo electrónico</label>
          <input type="email" id="correo" name="correo" value="<?= e($correo) ?>"
                 maxlength="150" autocomplete="username" required autofocus>
        </div>

        <div class="auth-campo">
          <label for="clave">Contraseña</label>
          <input type="password" id="clave" name="clave"
                 autocomplete="current-password" required>
        </div>

        <button type="submit" class="auth-boton">Entrar</button>
      </form>

      <p class="auth-pie">
        ¿Todavía no tienes cuenta?
        <a href="registro.php">Crear una cuenta</a>
      </p>
    </section>
  </main>

</body>
</html>
